#!/bin/bash

# check packages
# all dependent packages already installd while installing php
cd /usr/local/src
[ ! -f nginx-1.8.1 ] && wget https://nginx.org/download/nginx-1.8.1.tar.gz
tar -xzvf nginx-1.8.1.tar.gz && cd nginx-1.8.1
./configure --prefix=/usr/local/nginx --with-http_realip_module --with-http_ssl_module --with-http_sub_module --with-http_gzip_static_module --with-http_stub_status_module --with-pcre

curl https://raw.githubusercontent.com/cxuuu/LNMP/master/src/nginx -o /etc/init.d/nginx
curl https://raw.githubusercontent.com/cxuuu/LNMP/master/src/nginx.conf -o /usr/local/nginx/conf/nginx.conf
mkdir /usr/local/nginx/vhosts`

chkconfig --add nginx
