import logging
import requests
import re
from bs4 import BeautifulSoup
from packaging.version import parse as parse_version
from ruamel import yaml
from urllib.parse import urljoin, urlparse

logging.basicConfig(
    format='%(asctime)s %(levelname)s:%(message)s',
    level=logging.INFO,
)


class Workflow_Builder:

    def __init__(self, urls=[], regex=r'.*', file='', repo='ts3server'):
        self.visited_urls = []
        self.urls_to_visit = urls
        self.url_regex = re.compile('^(?:' + '|'.join(map(re.escape, urls)) + ')' + regex)
        self.file = file
        self.repo = repo

    def download_url(self, url):
        return requests.get(url).text

    def get_linked_urls(self, url, html):
        soup = BeautifulSoup(html, 'html.parser')
        for link in soup.find_all('a'):
            path = link.get('href')
            if path and urlparse(path).scheme == '':
                path = urljoin(url + '/', path)
            logging.debug(f'found: {path}')
            yield path

    def add_url_to_visit(self, url):
        if url not in self.visited_urls and url not in self.urls_to_visit and self.url_regex.search(url):
            logging.debug(f'add {url}')
            self.urls_to_visit.append(url)

    def crawl(self, url):
        html = self.download_url(url)
        for url in self.get_linked_urls(url, html):
            self.add_url_to_visit(url)

    def pad_zero(self, fragment):
        if type(fragment) is str:
            return re.sub(r'(\d+)', lambda f: f.group(1).zfill(2), fragment)
        else:
            return None

    def str_lower(self, fragment):
        if type(fragment) is str:
            return fragment.lower()
        else:
            return None

    def fragment_suffix_cleanup(self, fragment):
        if type(fragment) is str:
            return re.sub(r'[^a-z0-9]', '', fragment)
        else:
            return None

    def to_yaml_list(self, dict):
        lines = []
        for key in dict:
            lines.append(f'{key}={dict[key]}')
        return yaml.scalarstring.LiteralScalarString('\n'.join(lines))


    def generate_indicator(self, fragments):
        fragments = fragments[:5]
        fragments = list(map(self.pad_zero, fragments))
        fragments = list(filter(None, fragments))
        fragments = [fragment.replace('.', '_') for fragment in fragments]
        return '-'.join(fragments)

    def generate_job_name(self, fragments):
        fragments = fragments[:5]
        fragments = list(map(self.pad_zero, fragments))
        fragments = list(filter(None, fragments))
        fragments = [fragment.replace('.', '_') for fragment in fragments]
        return 'v' + '-'.join(fragments)

    def generate_tag(self, fragments):
        fragments = [fragments[0], fragments[1], fragments[4]]
        fragments = list(filter(None, fragments))
        return self.repo + ':' + '-'.join(fragments)

    def generate_dockerfile_name(self, fragments):
        fragments = ['Dockerfile', fragments[3], fragments[4]]
        fragments = list(filter(None, fragments))
        return '-'.join(fragments)

    def generate_docker_arch(self, fragments):
        fragments = [fragments[2], fragments[3]]
        fragments = list(filter(None, fragments))
        return '/'.join(fragments)

    def normalize_fragments(self, fragments):
        fragments = list(map(self.str_lower, fragments))
        result=[]
        result.append(fragments.pop(0))
        result.append(self.fragment_suffix_cleanup(fragments.pop(0)))
        match fragments.pop(0):
            #case 'linux_x86':
            #    result.append('linux')
            #    result.append('386')
            #    result.append(None)
            case 'linux_amd64':
                result.append('linux')
                result.append('amd64')
                result.append(None)
            case 'linux_alpine':
                result.append('linux')
                result.append('amd64')
                result.append('alpine')
            #case 'win32':
            #    result.append('windows')
            #    result.append('386')
            #    result.append(None)
            #case 'win64':
            #    result.append('windows')
            #    result.append('amd64')
            #    result.append(None)
            case _:
                result.append(None)
                result.append(None)
                result.append(None)
        result.append(fragments.pop(0))
        return list(result)

    def run(self):
        releases = {}
        while self.urls_to_visit:
            url = self.urls_to_visit.pop(0)
            logging.info(f'Crawling: {url}')
            try:
                if self.url_regex.search(url).group('extension'):
                    # 0 version
                    # 1 suffix
                    # 2 os
                    # 3 arch
                    # 4 suffix
                    # 5 extension
                    fragments = self.normalize_fragments(self.url_regex.search(url).groups())
                    if not fragments[2]:
                        continue
                    indicator = self.generate_indicator(fragments)
                    logging.info(f'adding {indicator}')
                    if indicator not in releases:
                        releases[indicator] = {
                            'fragments': fragments,
                            'dockerfile': '',
                            'tags': [],
                            'mirrors': []
                        }
                    releases[indicator]['mirrors'].append(url)
                else:
                    self.crawl(url)
            except Exception:
                logging.exception(f'Failed to crawl: {url}')
            finally:
                self.visited_urls.append(url)

        # detect latest version
        latest_version = '0'
        for key in sorted(releases):
            fragments = releases[key]['fragments']
            if not (fragments[1] or fragments[4]):
                if parse_version(latest_version) < parse_version(fragments[0]):
                    latest_version = fragments[0]
        logging.info(f'Last version: {latest_version}')

        # generate all information
        for key in sorted(releases):
            fragments = releases[key]['fragments']
            releases[key]['tags'].append(self.generate_tag(fragments))
            if not fragments[1]:
                if parse_version(latest_version) == parse_version(fragments[0]):
                    releases[key]['tags'].append(self.generate_tag(['latest'] + fragments[1:]))

        # generate jobs
        jobs = {}
        for key in sorted(releases):
            release = releases[key]
            jobs[self.generate_job_name(release['fragments'])] = {
                'runs-on': 'ubuntu-latest',
                'steps': [
                    {
                        'uses': 'actions/checkout@v2'
                    }, {
                        'name': 'Set up QEMU',
                        'uses': 'docker/setup-qemu-action@v1'
                    }, {
                        'name': 'Set up Docker Buildx',
                        'uses': 'docker/setup-buildx-action@v1'
                    }, {
                        'name': 'Login to DockerHub',
                        'uses': 'docker/login-action@v1',
                        'with': {
                            'username': '${{ secrets.DOCKERHUB_USERNAME }}',
                            'password': '${{ secrets.DOCKERHUB_TOKEN }}'
                        }
                    }, {
                        'name': 'Build and push',
                        'uses': 'docker/build-push-action@v2',
                        'with': {
                            'context': release['fragments'][2],
                            'file': f'{release["fragments"][2]}/{self.generate_dockerfile_name(release["fragments"])}',
                            'build-args': self.to_yaml_list({
                                'TS3SERVER_VERSION': release['fragments'][0],
                                'TS3SERVER_URL': release['mirrors'][0],
                                'TS3SERVER_ARCHIVE': release['mirrors'][0].split('/').pop(),
                            }),
                            'push': 'true',
                            'platforms': self.generate_docker_arch(release['fragments']),
                            'tags': ','.join(release['tags'])
                        }
                    }
                ]
            }

        workflow = yaml.load(open(self.file, 'r'), Loader=yaml.RoundTripLoader)
        workflow['jobs'] = jobs
        yaml.dump(workflow, open(self.file, 'w'), Dumper=yaml.RoundTripDumper)


if __name__ == '__main__':
    Workflow_Builder(
        urls=[
            'https://files.teamspeak-services.com/releases/server/',
            'https://files.teamspeak-services.com/pre_releases/server/',
            'http://dl.4players.de/ts/releases/',
            'http://dl.4players.de/ts/releases/pre_releases/server/',
        ],
        regex=r'(?:(?P<version>3(?:\.[0-9]+)+)(?:-(?P<suffix>[0-9a-zA-Z-]+(?:\.[0-9]+)?))?(?:\/(?:teamspeak3-server_(?P<arch>[0-9a-z_-]+)-(?:3(?:\.[0-9]+)+)(?:-(?:[0-9a-zA-Z-]+(?:\.[0-9]+)?))?\.(?P<extension>(?:\.?[a-z][0-9a-z]+){1,2}))?)?)?$',
        file='.github/workflows/build.yml',
        repo='hackebein/ts3server'
    ).run()
