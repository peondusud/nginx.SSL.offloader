#!/bin/bash

 mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
 rm -rf /etc/nginx/snippets /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

SHELL_PATH=$(dirname $0)
mv -f ${SHELL_PATH}/nginx/* /etc/nginx/
mkdir -p /var/spool/nginx

openssl dhparam -out /etc/nginx/ssl/dhparam.pem 4096


# let's encrypt part
apt-get update
apt-get install git
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt --depth=1
cd /opt/letsencrypt
git pull




echo "/opt/letsencrypt/letsencrypt-auto certonly --rsa-key-size 4096 --webroot --webroot-path /var/www/mondomaine.fr -d domain.org"

#certs will be save in /etc/letsencrypt/live/

mkdir -p /etc/letsencrypt/configs
"
# Uncomment and update to generate certificates for the specified domains.
# domains = example.com, www.example.com
domains = <mydomain>

# Email used for registration and recovery contact.
#email = webmaster@gfdg.org
email = <mymail>


rsa-key-size = 4096

# Official server
#server = https://acme-v01.api.letsencrypt.org/directory
# staging server to obtain test (invalid) certs
server = https://acme-staging.api.letsencrypt.org/directory 

# turn off the ncurses UI, we want this to be run as a cronjob
text = True

# authenticate by placing a file in the webroot (under .well-known/acme-challenge/)
authenticator = webroot
webroot-path = /var/www/letsencrypt
" > /etc/letsencrypt/configs/mydomain.conf



echo "
#!/bin/sh
for conf in $(ls /etc/letsencrypt/configs/*.conf); do
  /opt/letsencrypt/letsencrypt-auto --renew --config "$conf" certonly
done
service nginx reload
" > /etc/cron.monthly/renew_certs


/opt//letsencrypt-auto --agree-tos --config /etc/letsencrypt/configs/mydomain.conf certonly 
