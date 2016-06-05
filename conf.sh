#!/bin/bash

SHELL_PATH=$(dirname $0)
MYDOMAIN=peon.peon.org
MYMAIL=webmaster@${MYDOMAIN}

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
rm -rf /etc/nginx/snippets /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
cp -rf ${SHELL_PATH}/nginx/* /etc/nginx/
mkdir -p /var/spool/nginx
mkdir -p /var/www/letsencrypt
mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/dhparam.pem ]; then
    openssl dhparam -out /etc/nginx/ssl/dhparam.pem 1024
    #openssl dhparam -out /etc/nginx/ssl/dhparam.pem 4096
else
    openssl dhparam -inform PEM -in /etc/nginx/ssl/dhparam.pem -check
fi


# Let's encrypt part
apt-get install git
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt --depth=1
mkdir -p /etc/letsencrypt/configs
cp -f ${SHELL_PATH}/letsencrypt.ini /etc/letsencrypt/configs/${MYDOMAIN}.conf
sed -i "s|<domain>|${MYDOMAIN}|" /etc/letsencrypt/configs/${MYDOMAIN}.conf
sed -i "s|<mail>|${MYMAIL}|" /etc/letsencrypt/configs/${MYDOMAIN}.conf
sed -i "s|<domain>|${MYDOMAIN}|" /etc/nginx/conf.d/sslproxy.conf
sed -i "s|<domain>|${MYDOMAIN}|" /etc/nginx/sites-available/backend.conf
# disable nginx ssl
sed -i 's|^\(ssl .*\)on;$|\1off;|' /etc/nginx/conf.d/sslproxy.conf
sed -i "s|^\(ssl_certificate\)|#\1|g" /etc/nginx/conf.d/sslproxy.conf
ln -s /etc/nginx/sites-available/letsencrypt.conf /etc/nginx/sites-enabled/letsencrypt.conf;
service nginx reload;

# Script to renew generated certs
echo '#!/bin/sh
for conf in $(ls /etc/letsencrypt/configs/*.conf); do
  /opt/letsencrypt/letsencrypt-auto renew --config "$conf" certonly
done
service nginx reload' > /etc/cron.monthly/renew_certs

/opt/letsencrypt/letsencrypt-auto --agree-tos --config /etc/letsencrypt/configs/${MYDOMAIN}.conf certonly 
echo "Let's encrypt Certs will be save in /etc/letsencrypt/live/"

# enable nginx ssl
sed -i "s|^\(ssl .*\)off;$|\1on;|"  /etc/nginx/conf.d/sslproxy.conf
#ln -s /etc/nginx/sites-available/backend.conf /etc/nginx/sites-enabled/backend.conf
#service nginx reload
