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
sudo openssl genrsa -des3 -rand /etc/hosts -out /etc/postfix/ssl/smtpd.key 1024
sudo chmod 600 /etc/postfix/ssl/smtpd.key
sudo openssl req -new -key /etc/postfix/ssl/smtpd.key -out  /etc/postfix/ssl/smtpd.csr
sudo openssl x509 -req -days 3650 -in /etc/postfix/ssl/smtpd.csr -signkey /etc/postfix/ssl/smtpd.key -out /etc/postfix/ssl/smtpd.crt
sudo openssl rsa -in /etc/postfix/ssl/smtpd.key -out /etc/postfix/ssl/smtpd.key.unencrypted
sudo mv -f /etc/postfix/ssl/smtpd.key.unencrypted /etc/postfix/ssl/smtpd.key
sudo openssl req -new -x509 -extensions v3_ca -keyout /etc/postfix/ssl/cakey.pem -out /etc/postfix/ssl/cacert.pem -days 3650

# restart postfix and saslauthd
sudo /etc/init.d/postfix restart
sudo /etc/init.d/saslauthd start
