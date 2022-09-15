#!/bin/bash
yum install -y git httpd24 php70 mysql56-server php70-mysqlnd gcc openssl-devel* nmap -y
mkdir /tools

curl -o /tmp/server-basics.sh https://raw.githubusercontent.com/peeweeh/server-basics/master/amazon/setup/base.sh && sh /tmp/server-basics.sh
yum install -y httpd24 php56 php56-mysqlnd
service httpd start
chkconfig httpd on
groupadd www
usermod -a -G www ec2-user
chown -R root:www /var/www
chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} +
find /var/www -type f -exec sudo chmod 0664 {} +