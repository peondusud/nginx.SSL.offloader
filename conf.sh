#!/bin/bash


# let's encrypt part
apt-get update
apt-get install git
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt --depth=1
cd /opt/letsencrypt
sudo git pull



/opt/letsencrypt/letsencrypt-auto certonly --rsa-key-size 4096 --webroot --webroot-path /var/www/mondomaine.fr -d domain.org

#certs will be save in /etc/letsencrypt/live/
ls /etc/letsencrypt/live/
