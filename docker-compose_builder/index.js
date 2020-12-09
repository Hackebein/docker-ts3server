const Crawler = require('crawler');
const esr = require('escape-string-regexp');
const fs = require('fs');
const Logger = require('logger').Logger;
const url = require('url');
const yaml = require('js-yaml');
const _ = require('underscore');

const log = new Logger();
//log.setLevel('fatal');

const RegExVersion = /(3(?:\.[0-9]+)+)(?:-([0-9a-zA-Z-]+(?:\.[0-9]+)?))?/;
const RegExServerFilename = /teamspeak3-server_([0-9a-z_-]+)-(3(?:\.[0-9]+)+)(?:-([0-9a-zA-Z-]+(?:\.[0-9]+)?))?((?:\.[a-z][0-9a-z]+){1,2})/;

const binary = process.argv.shift();
const file = process.argv.shift();
const output = process.argv.shift();
const repo = process.argv.shift();
const context = process.argv.shift();
const oses = process.argv;

let releases = [];
let services = {};
let crawler = new Crawler({
    logger: log,
    maxConnections: 1,
    skipDuplicates: true,
    timeout: 1000,
    retryTimeout: 1500,
    preRequest: (options, done) => {
        let error = new Error();
        if(!_.isRegExp(options.jail)) {
            log.error('Jail is missing or not a RegExp');
            error.op = 'abort';
            url.resolve(res.request.uri.href, $(e).attr("href"));
        } else if(!options.jail.test(options.uri)) {
            log.info('Out of Jail: '  + options.uri);
            error.op = 'abort';
        }
        if(_.isUndefined(error.op)) {
            setTimeout(done, 500);
        } else {
            done(error);
        }
    },
    callback: (error, res, done) => {
        if(error) {
            log.error(error);
        } else {
            log.info(res.options.method + " " + res.request.uri.href + " (" + res.headers['content-type'] + ")");
            switch (res.headers['content-type']) {
                case 'text/html':
                case 'text/html;charset=UTF-8':
                    switch (res.options.method) {
                        case 'GET':
                            if(res.$) {
                                var $ = res.$;
                                $("a[href!='']").each((i, e) => {
                                    requestUrl = url.format(url.resolve(res.request.uri.href, $(e).attr("href")), {
                                        auth: false,
                                        fragment: false,
                                        search: false,
                                    });
                                    crawler.queue({
                                        uri: requestUrl,
                                        jail: res.options.jail,
                                        method: 'HEAD',
                                    });
                                });
                            } else {
                                log.error('Can\'t inject jQuery');
                            }
                            break;
                        case 'HEAD':
                            crawler.queue({
                                uri: res.request.uri.href,
                                jail: res.options.jail,
                                method: 'GET',
                            });
                            break;
                        default:
                            log.error('Unexpected request method ' + res.options.method);
                    }
                    break;
                // FreeBSD server archiv
                // Linux server archiv
                case 'application/x-bzip2':
                case 'application/x-gzip':
                case 'application/x-tar':
                // Windows server archiv
                // MacOS server archiv
                case 'application/zip':
                    switch (res.options.method) {
                        case 'HEAD':
                            let pathSegments = res.request.uri.pathname.split('/');
                            let filename = pathSegments.pop();
                            if(RegExServerFilename.test(filename)) {
                                let release = _.object(['versionRaw', 'version', 'stage'], RegExVersion.exec(_.filter(pathSegments, segment => RegExVersion.test(segment)).pop()));
                                if(_.isString(release.stage)) {
                                    release.stage = release.stage.replace('-', '').replace('.', '').toLowerCase();
                                }
                                //release.versionParts = _.object(['major', 'minor', 'maintenance', 'build'], release.version.split('.'));
                                release.os = RegExServerFilename.exec(filename)[1].replace('-', '_');
                                //"freebsd_amd64", "freebsd_x86", "linux_alpine", "linux_amd64", "linux_x86", "mac", "win32", "win64"
                                release.platform = release.os
                                    .replace('freebsd_amd64', 'linux/amd64')
                                    .replace('freebsd_x86', 'linux/386')
                                    .replace('linux_alpine', 'linux/amd64')
                                    .replace('linux_amd64', 'linux/amd64')
                                    .replace('linux_x86', 'linux/386')
                                    .replace('mac', 'osx')
                                    .replace('win32', 'windows/386')
                                    .replace('win64', 'windows/amd64')
                                    .replace('_', '/');
                                release.mirror = res.request.uri;
                                release.name = release.version;
                                if(_.isString(release.stage)) {
                                    release.name += '-' + release.stage;
                                }
                                release.name += '-' + release.os;
                                release.tags = [
                                    release.name,
                                ];
                                if(_.contains(oses, release.os)) {
                                    releases.push(release);
                                } else {
                                    log.info('Unsupported os ' + release.os);
                                }
                            } else {
                                log.error('Unexpected filename ' + filename);
                            }
                            break;
                        default:
                            log.error('Unexpected request method ' + res.options.method);
                    }
                    break;
                // Windows client binary
                case 'application/x-msdos-program':
                // Linux client binary
                case 'application/x-makeself':
                // MacOS client binary
                case 'application/x-apple-diskimage':
                    // ignore
                    break;
                default:
                    log.warn('Unhandled content-type ' + res.headers['content-type'] + ' (' + res.request.uri.href + ')');
            }
        }
        done();
    },
});

crawler.queue({
    uri: 'https://files.teamspeak-services.com/releases/server/',
    jail: new RegExp('^' + esr('https://files.teamspeak-services.com/releases/server/') + '(?:' + RegExVersion.source + '(?:' + esr('/') + '(?:' + RegExServerFilename.source + ')?' + ')?' + ')?' + '$'),
});

crawler.queue({
    uri: 'https://files.teamspeak-services.com/pre_releases/server/',
    jail: new RegExp('^' + esr('https://files.teamspeak-services.com/pre_releases/server/') + '(?:' + RegExVersion.source + '(?:' + esr('/') + '(?:' + RegExServerFilename.source + ')?' + ')?' + ')?' + '$'),
});

crawler.queue({
    uri: 'http://dl.4players.de/ts/releases/',
    jail: new RegExp('^' + esr('http://dl.4players.de/ts/releases/') + '(?:' + RegExVersion.source + '(?:' + esr('/') + '(?:' + RegExServerFilename.source + ')?' + ')?' + ')?' + '$'),
});

crawler.queue({
    uri: 'http://dl.4players.de/ts/releases/pre_releases/server/',
    jail: new RegExp('^' + esr('http://dl.4players.de/ts/releases/pre_releases/server/') + '(?:' + RegExVersion.source + '(?:' + esr('/') + '(?:' + RegExServerFilename.source + ')?' + ')?' + ')?' + '$'),
});

crawler.on('drain', () => {
    if(!releases.length) {
        return;
    }
    releases = _.chain(releases)
        .groupBy('name')
        .map(mirrors => _.chain(mirrors).first().omit('mirror').extend({mirrors: _.map(mirrors, 'mirror')}).value())
        .sortBy(release => release.version.replace(/\d+/g, n => +n+1000) + (_.isUndefined(release.stage) ? '0' : '1') + release.os + (_.isUndefined(release.stage) ? '' : release.stage))
        .value();
    _.chain(releases).map('version').uniq().each((version) => {
        let lastIndex = -1;
        _.chain(oses).each((os) => {
            if(lastIndex == -1) {
                lastIndex = _.findLastIndex(releases, release => release.os === os && release.version === version && _.isUndefined(release.stage));
            }
        });
        if(lastIndex >= 0) {
            releases[lastIndex].tags.push(version);
        }
    });
    _.each(oses, (os) => {
        let lastIndex = _.findLastIndex(releases, release => release.os === os && !_.isUndefined(release.stage));
        if(lastIndex >= 0) {
            releases[lastIndex].tags.push('latest-pre-' + os);
        }
    });
    _.each(oses, (os) => {
        let lastIndex = _.findLastIndex(releases, release => release.os === os && _.isUndefined(release.stage));
        if(lastIndex >= 0) {
            releases[lastIndex].tags.push('latest-' + os);
        }
    });
    let lastIndex = -1;
    _.chain(oses).each((os) => {
        if(lastIndex == -1) {
            lastIndex = _.findLastIndex(releases, release => release.os === os && _.isUndefined(release.stage));
        }
    });
    if(lastIndex >= 0) {
        releases[lastIndex].tags.push('latest');
    }
    _.chain(releases).each((release) => {
        _.chain(release.tags).each((tag) => {
            if(release.name == tag) {
                mirror = release.mirrors.shift();
                services[tag] = {
                    image: repo + ':' + tag,
                    build: {
                        context: context,
                        dockerfile: 'Dockerfile.' + release.os,
                        args: {
                            TS3SERVER_VERSION: release.version,
                            TS3SERVER_URL: mirror.href,
                            TS3SERVER_ARCHIVE: mirror.path.split('/').pop(),
                        },
                    },
                    platform: release.platform,
                };
            } else {
                services[tag] = {
                    extends: release.name,
                    image: repo + ':' + tag,
                };
            }
        });
    });
    fs.writeFile(output, yaml.dump({
        version: '2.4',
        services: services,
    }), (err) => {
        if(err) {
            log.error(err);
        }
        log.info('job done');
    });
});
