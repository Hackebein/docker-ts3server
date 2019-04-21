#!/usr/bin/env expect
log_user 0

# function infos
proc ts3query {_command} {
	global output command response error_id error_msg notice
	send "$_command\n"
	set command   ""
	set response  ""
	set error_id  -1
	set error_msg "unknown"
	set notice    ""
	expect -regexp "^\[\r\n]*(\[^\r\n]*)\[\r\n]+(\[^\r\n]*)\[\r\n]*error id=(\[0-9]+) msg=(\[^\r\n]*)\[\r\n]+(\[^\r\n]*)" {
		set output    "$expect_out(buffer)"
		set command   "$expect_out(1,string)"
		# TODO: if substring 2 is empty set substring 5
		set response  "$expect_out(2,string)"
		set error_id  "$expect_out(3,string)"
		set error_msg "$expect_out(4,string)"
		set notice    "$expect_out(5,string)"
	}
	send_user "> $command\n"
	send_user "\t status:   $error_msg ($error_id) $notice\n"
	#send_user "\t response: $response\n"
	
	array set data {}
	set index -1
	foreach dataset [split $response "|"] {
		incr index
		set "data($index)" $dataset
		send_user "\t\t $dataset\n"
		foreach {key value} [split $dataset " ="] {
			set "data($index)($key)" "$value"
		}
	}
	return [array get data]
}

# function infos
proc ts3connect {_host _port} {
	global spawn_id motd
	# TODO: is timeout working?
	set timeout 30

	# connect
	if [catch "spawn telnet $_host $_port" pid] {
		send_user "Unable to spawn telnet!\n"
		exit 1
	}

	# wait for motd
	expect -regexp "TS3\[\r\n]+(\[^\r\n]*)\[\r\n]+"
	set motd "$expect_out(1,string)"
}

ts3connect localhost $env(TS3SERVER_QUERY_PORT)
#send_user "$motd\n"

# 
ts3query "login client_login_name=serveradmin client_login_password=$env(TS3SERVER_QUERY_PASSWORD)"
array set serverlist [ts3query "serverlist -short"]
foreach index [array names serverlist -regexp "^\[0-9]+$"] {
	array set virtualserver {}
	foreach {key value} [split "$serverlist($index)" " ="] {
		set "virtualserver($key)" "$value"
	}
	if [string equal "$virtualserver(virtualserver_status)" "online"] {
		#puts "$virtualserver(virtualserver_id) is $virtualserver(virtualserver_status)"
		ts3query "use sid=$virtualserver(virtualserver_id)"
		ts3query "clientupdate client_nickname=Server"
		array set clientlist [ts3query "clientlist"]
		foreach index [array names clientlist -regexp "^\[0-9]+$"] {
			array set client {}
			foreach {key value} [split "$clientlist($index)" " ="] {
				set "client($key)" "$value"
			}
			if [string equal "$client(client_type)" "0"] {
				ts3query "clientkick clid=$client(clid) reasonid=5 reasonmsg=Server\\swird\\swegen\\sWartungsarbeiten\\sneugestartet!"
			}
		}
		ts3query "serverstop sid=$virtualserver(virtualserver_id)"
	}
}
ts3query "serverprocessstop"

# do magic shit
ts3query "quit"
expect eof
