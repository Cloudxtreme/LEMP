#
# Discription
- These confs are used to use nginx as a very efficient HTTP load balancer to distribute traffic to several application servers.
- The loadbalancer.conf is used on the distibutor machine which used to detect the trafiic requests and distibute the requests to the real web servers.

There are different load balancing mechanisms:
round-robin — requests to the application servers are distributed in a round-robin fashion,
least-connected — next request is assigned to the server with the least number of active connections,
ip-hash — a hash-function is used to determine what server should be selected for the next request (based on the client’s IP address).

And you can set weight for different real server. The default weight value is 1.


# Usage:

- put loadbalancer.conf in distributor machine's /usr/local/nginx/conf/vhosts/
- put the wordpress.conf of this src folder on real servers' /usr/local/nginx/conf/vhosts


# Example:

## Machines & roles:
|Machines|Roles|
|:--:|:--:|
|A|Distributor|
|B|Real server 1 & Source server|
|C|Real server 2|
|D|Database(MySQL)|

## Steps:
1. Database. Grant priviliges to wordpress MySQL user @ machine B & C.
2. Storage.
    - Yum install nfs-utils both on machine B & C.
    - Tar wordpress.tar.gz to B:/var/www/wordpress
    - vim /etc/exports on expose machine B's WordPress folder to C.
    - ON C, mount -t nfs -o nfsvers=3 B:/path /path (maybe you should write this mount command to /etc/rc.local)
    - chkconfig nfs on
3. Check.
    - Both B and C can access the wordpress folder (which is on machine B)
    - Both B and C can write & read data on D (MySQL server)
    - Both B and C can run Nginx and php-fpm
    - A should run Nginx as distibutor
    - Put loadbalancer.conf on A:/usr/local/nginx/conf/vhosts/
4. Restart 
