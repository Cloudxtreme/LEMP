# Uncompleted


# For High Avaliable
Those conf are aimed at setting up High Avaliable for Nginx load balance.

There are conf files in src folder.

# Simple example
This is a little simple example for for HA configurations.

## Preparation

### Step 1. Network & machines
I use a router to provide network.

And use virtual machines on my computer by VirtualBox.

Machines & Roles

|Machine|Role|Notes|
|:-:|:-:|:-:|
|one|master server|
|two|backup server|works after one's down|

Machines & IP

|Machine|Public IP|Private IP(Internal in BirtualBox)|
|:-:|:-:|:-:|
|router|192.168.123.1|
|host|192.168.123.111|
|Virtual IP|192.168.123.119|Floating IP|
|one|192.168.123.131 eth0|192.168.1.111 eth1|
|two|192.168.123.132 eth0|192.168.1.112 eth1|
|**Notes**|eth0 provides service|eth1 broadcasts heartbeats over|

Packages

- yum install epel-release
- yum install heartbeat libnet
- Nginx has set up both on one and two
- (**make sure** There is nginx in /etc/init.d)
- [Nginx setup script](https://github.com/cxuuu/LNMP/tree/master/scripts)  and [conf files](https://github.com/cxuuu/LNMP/tree/master/src)

### Step 2. Configurations
1. master server (machine one)
    - echo "192.168.123.131 one" >> /etc/hosts
    - echo "192.168.123.132 two" >> /etc/hosts
    - cd /usr/share/doc/heartbeat-3.0.4/ && cp authkeys haresources ha.cf /etc/ha.d/ && cd /etc/ha.d
    - choose md5 in authkeys and chmod 600 authkeys
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
      - node	one
      - node	four
      - ping 192.168.123.1
      - respawn hacluster /usr/lib64/heartbeat/ipfail
      
2. backup server (machien two)
    - /etc/hosts, authkey and haresources are same as one's
    - only one line is different from one's in ha.cf
    - ucast eth1 192.168.1.111

### Step 3. Testing
- stop nginx service on one & two
- start heartbeat service (master first)



# Normal example
1. For normal use.
2. On the base of [Nginx load balance](https://github.com/cxuuu/LNMP/tree/master/loadbalance).

The distributor distributes and delivers traffic between clients and real server.
Some work should be done to make sure that the distributor is always avaliable.
The key thought is that backup distributor starts to work after main distributor's down.

## Preparation

### Step 1. Machines & Roles
|Machine|Role|Public IP|Private IP(Internal in BirtualBox)|Notes|
|:-:|:-:|:-:|:-:|:-:|
|host|for testing|192.168.123.111|
|Virtual IP|Floating IP|192.168.123.119|
|one|main distributor|192.168.123.131 eth0|192.168.1.111 eth1|
|two|real server 1|192.168.123.132 eth0|192.168.1.112 eth1|
|three|real server 2|192.168.123.133 eth0|192.168.1.113 eth1|
|four|data server (MySQL)|192.168.123 eth0|192.168.1.114 eth1|**backup distributor**|

### Step 2. Packages
* check epel
* check LNMP
* install heartbeat libnet

### Step 3. Configurations
1. Configurations of Nginx on one & four are the same. Set up load balance.
2. set up heartbeat on one & four (almost same as the sample version above)

### Step 4. Testing
1. add "192.168.123.119 1024.com www.1024.com" to /etc/hosts on host computer
2. browse 1024.com on host.
3. stop machine one & go on
4. stop heartbeat on one & go on
