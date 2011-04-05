#
# Author: Michael Klein
# A script that installs zarafa on ubuntu 10.04
# configures postfix as MTA
# and secures postfix

sudo apt-get update
sudo apt-get install apache2 mysql-server postfix libsasl2-2 sasl2-bin libsasl2-modules

# stop postfix and configure it 
sudo /etc/init.d/postfix stop
sudo cat add_to_main >> /etc/postfix/main.cf
sudo cat smtpd_auth_cfg >> /etc/postfix/sasl/smtpd.conf

# Authentication via saslauthd
sudo mkdir -p /var/spool/postfix/var/run/saslauthd
sudo cat new_saslauthd > /etc/default/saslauthd
sudo adduser postfix sasl

# create certificates for TLS
sudo mkdir /etc/postfix/ssl/
sudo cd /etc/postfix/ssl/
sudo openssl genrsa -des3 -rand /etc/hosts -out smtpd.key 1024
sudo chmod 600 smtpd.key
sudo openssl req -new -key smtpd.key -out smtpd.csr
sudo openssl x509 -req -days 3650 -in smtpd.csr -signkey smtpd.key -out smtpd.crt
sudo openssl rsa -in smtpd.key -out smtpd.key.unencrypted
sudo mv -f smtpd.key.unencrypted smtpd.key
sudo openssl req -new -x509 -extensions v3_ca -keyout cakey.pem -out cacert.pem -days 3650

# restart postfix and saslauthd
sudo /etc/init.d/postfix restart
sudo /etc/init.d/saslauthd start
