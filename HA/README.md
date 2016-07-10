# For High Avaliable
Those conf are aimed at setting up High Avaliable for Nginx load balance.

# Simple example
This is a little simple example for for HA configurations.
## Preparation
### Network & machines
I use a router to provide network,
And use virtual machines on my computer by VirtualBox
1. Machines & Roles
|Machine|Role|Note|
|:--:|:--:|:--:|
|one|master server||
|two|backup server|after one's down, two works|
2. Machines & IP
|Machine|Public IP|Internal IP|
|:--:|:--:|:--:|
|router|192.168.123.1||
|host|192.168.123.111||
|Virtual IP|192.168.123.119|Floating IP|
|one|192.168.123.131 eth0|192.168.1.111 eth1|
|two|192.168.123.132 eth0|192.168.1.112 eth1|
|**Notes**| eth0 provides service|eth1 broadcasts heartbeats over|
### Packages
1. yum install epel-release
2. yum install heartbeat libnet
3. **make sure** that you has set up Nginx both on machine one & two
### Configurations
1. master (machine one)
	- echo "192.168.123.131 one" >> /etc/hosts
	- echo "192.168.123.132 two" >> /etc/hosts
	- cd /usr/share/doc/heartbeat-3.0.4/ && cp authkeys haresources ha.cf /etc/ha.d/ && cd /etc/ha.d
	- choose md5 in authkeys
	- echo "one 192.168.123.119/24/eth0:0 nginx" >> haresources
	- uncomment and set in ha.cf
		- debugfile /var/log/ha-debug
		- logfile	/var/log/ha-log
		- logfacility	local0
		- keepalive 2
		- deadtime 30
		- warntime 10
		- initdead 60
		- udpport	694
		- ucast eth1 192.168.1.114
		- auto_failback on
		- node	neo
		- node	four
		- ping 192.168.123.1
		- respawn hacluster /usr/lib64/heartbeat/ipfail
2. backup (machien two)

### Testing

# Normal usage
