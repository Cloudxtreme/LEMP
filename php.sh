#!/bin/bash
check_swap() {
if [ 0 -ne `free |grep Swap |awk '{print $2}'` ]
then
    dd if=/dev/zero of=/tmp/swap bs=4k count=262144
    mkswap /tmp/swap && swapon /tmp/swap
    echo '/tmp/swap               none                    swap    sw              0 0' >> /etc/fstab
fi
}
check_old() {
if [ -d /usr/local/php/ ]
then
    mv /usr/local/php /usr/local/php_`date +%F-%T`
fi
}
check_src() {
cd /usr/local/src/
if [ ! -f php-5.6.21.tar.gz ]
then
    wget https://php.net/distributions/php-5.6.21.tar.gz
fi
tar -xzvf php-5.6.21.tar.gz
}

check_packages() {
if ! rpm -qa|grep -q "^$1"
then
    yum install $1 -y
else
    echo "$1 already installed"
fi
}


# Install dependent packages
for p in epel-release gcc libxml2-devel bzip2-devel libcurl-devel libjpeg-devel libpng-devel openssl-devel zlib-devel freetype-devel libmcrypt-devel 
do
    check_packages $p
done

check_old
check_swap
check_src
cd /usr/local/src/php-5.6.21
./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache2/bin/apxs --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-mysql-sock=/tmp/mysql.sock --enable-fpm --with-fpm-user=php-fpm --with-fpm-group=php-fpm --with-bz2 --with-libxml-dir --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-iconv-dir --with-zlib-dir --with-mcrypt --with-curl --with-openssl --with-pear --enable-exif --enable-gd-native-ttf --enable-mbstring --enable-soap --enable-sockets
make && make install
cp php.ini-production /usr/local/php/etc/php.ini
# cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
curl https://raw.githubusercontent.com/cxuuu/LNMP/master/src/php-fpm.conf /usr/local/php/etc/php-fpm.conf
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chkconfig --add php-fpm
