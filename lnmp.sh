#!/bin/bash

# exec 1>> right.log 2>>error.log

# all urls
#mysql_64_url='http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.30-linux-glibc2.5-x86_64.tar.gz'
#mysql_32_url='http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.30-linux-glibc2.5-i686.tar.gz'

# all functions

# primary function
check() {
if [ $? != 0 ]
then
    echo "This a error, shell script exits now"
    exit 1
fi
}


# functions for mysql
check_mysqlpath() {
if env|grep PATH|grep -q /usr/local/mysql
then
    echo "MySQL's path already exits, and it's right"
else
    echo -e '#!/bin/bash\nexport PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile.d/PATH.sh
fi
check
}

# functions for php
check_swap() {
if [ 0 -eq `free |grep Swap |awk '{print $2check
}'` ]
then
    dd if=/dev/zero of=/tmp/swap bs=4k count=262144
    mkswap /tmp/swap && swapon /tmp/swap
    echo '/tmp/swap               none                    swap    sw              0 0' >> /etc/fstab
fi
check
}


# common functions
check_user() {
for user in mysql php-fpm
do
    if ! grep -q $user /etc/passwd
    then
        useradd -r -s /bin/false $user
    else
        echo "$user user already exists"
    fi
done
check
}
check_old_base () {
if [ -f $1 ] || [ -d $1 ];
then
    mv $1 $1-`date +%F-%T`
fi
check
}

check_old() {
for old in /etc/my.cnf /etc/init.d/mysqld /etc/init.d/nginx /etc/init.d/php-fpm /data/mysql /usr/local/nginx /usr/local/php
do
   check_old_base $old
done
check
}

packages_setup() {
yum install -y epel-release
yum install -y gcc libaio pcre-devel openssl-devel zlib-devel libxml2-devel bzip2-devel libcurl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel 
check
}

# MySQL setup script
mysql_setup() {
check_mysqlpath
cd /usr/local/src
[ ! -f mysql-5.6.30-linux-glibc2.5-x86_64.tar.gz ] && wget http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.30-linux-glibc2.5-x86_64.tar.gz
tar -xzf mysql-5.6.30-linux-glibc2.5-x86_64.tar.gz
mv mysql-5.6.30-linux-glibc2.5-x86_64 /usr/local/mysql
cd /usr/local/mysql
chown -R  mysql:mysql .
[ ! -d /data/mysql ] && mkdir -p /data/mysql
./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
chown -R root .
chown -R mysql:mysql /data/mysql
cp support-files/mysql.server /etc/init.d/mysqld
sed -i 's#^datadir=#datadir=/data/mysql#' /etc/init.d/mysqld
cp support-files/my-default.cnf /etc/my.cnf
sed -i 's/# datadir = ...../datadir=\/data\/mysql/' /etc/my.cnf
chkconfig --add mysqld
check
}

# php setup script
php_setup() {
check_swap
cd /usr/local/src/
[ ! -f php-5.6.21.tar.gz ] && wget https://php.net/distributions/php-5.6.21.tar.gz
tar -xzvf php-5.6.21.tar.gz && cd php-5.6.21
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-mysql-sock=/tmp/mysql.sock --enable-fpm --with-fpm-user=php-fpm --with-fpm-group=php-fpm --with-bz2 --with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-iconv-dir --with-zlib-dir --with-mcrypt --with-curl --with-openssl --with-pear --enable-exif --enable-gd-native-ttf --enable-mbstring --enable-soap --enable-sockets
make && make install
cp php.ini-production /usr/local/php/etc/php.ini
# cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
curl https://raw.githubusercontent.com/cxuuu/LNMP/master/src/php-fpm.conf -o /usr/local/php/etc/php-fpm.conf
mkdir /usr/local/php/logs
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod a+x /etc/init.d/php-fpm
chkconfig --add php-fpm
check
}

# nginx setup
nginx_setup() {
cd /usr/local/src
[ ! -f nginx-1.8.1.tar.gz ] && wget https://nginx.org/download/nginx-1.8.1.tar.gz
tar -xzvf nginx-1.8.1.tar.gz && cd nginx-1.8.1
./configure --prefix=/usr/local/nginx --with-http_realip_module --with-http_ssl_module --with-http_sub_module --with-http_gzip_static_module --with-http_stub_status_module --with-pcre
make && make install
curl https://raw.githubusercontent.com/cxuuu/LNMP/master/src/nginx -o /etc/init.d/nginx
chmod a+x /etc/init.d/nginx
curl https://raw.githubusercontent.com/cxuuu/LNMP/master/src/nginx.conf -o /usr/local/nginx/conf/nginx.conf
echo -e "<?php\nphpinfo();\n?>" > /usr/local/nginx/html/index.php
mkdir /usr/local/nginx/conf/vhosts
chkconfig --add nginx
check
}


# iptables & selinux
ip_selinux() {
iptables-save > /etc/sysconfig/iptables_`date +%s`
iptables -F
service iptables save
if [ `getenforce` != "Disabled" ]
then
    setenforce 0
    if ! grep -q SELINUX=disabled  /etc/selinux/config
    then
        sed "s/`grep ^SELINUX=  /etc/selinux/config`/SELINUX=disabled/" /etc/selinux/config
    fi
fi
check
}
# Final
read -p "Are you sure that you want to install LAMP:(YES/No) " option
case $option in
YES)
    ip_selinux
    check_user
    check_old
    packages_setup
    mysql_setup
    php_setup
    nginx_setup
    ;;
*)
    echo "Bye"
    ;;
esac
