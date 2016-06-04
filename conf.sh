#!/bin/bash

 mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
 rm -rf /etc/nginx/snippets

SHELL_PATH=$(dirname $0)
mv ${SHELL_PATH}/nginx/* /etc/nginx/



# let's encrypt part
apt-get update
apt-get install git
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt --depth=1
cd /opt/letsencrypt
sudo git pull



echo "/opt/letsencrypt/letsencrypt-auto certonly --rsa-key-size 4096 --webroot --webroot-path /var/www/mondomaine.fr -d domain.org"

#certs will be save in /etc/letsencrypt/live/
ls /etc/letsencrypt/live/
