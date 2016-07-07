#

This conf is used to use nginx as a very efficient HTTP load balancer to distribute traffic to several application servers.

This conf is used on the distibutor machine which used detect the trafiic requests and distibute the requests to the real web servers.

There are different load balancing mechanisms:

round-robin — requests to the application servers are distributed in a round-robin fashion,
least-connected — next request is assigned to the server with the least number of active connections,
ip-hash — a hash-function is used to determine what server should be selected for the next request (based on the client’s IP address).

And you can set weight for different real server. The default weight value is 1.



Usage:

put loadbalancer.conf in distributor machine's /usr/local/nginx/conf/vhosts/
put the wordpress.com of this src folder on real servers' /usr/local/nginx/conf/vhosts


Example:

WordPress

Distributor: machine one
Real server: machine two
Real server: machine three
Database(MySQL): machine four

1, Database. Grant priviliges to wordpress MySQL user @ machine two & three
2, Storage. Yum install nfs-utils both on machine two & three.
            vim /etc/exports on expose machine two's WordPress folder to three.
            mount -t nfs -o nfsvers=3 two:/path /path (maybe you should write this mount command to /etc/rc.local)
            chkconfig nfs on 