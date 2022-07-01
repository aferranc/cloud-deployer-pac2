#!/bin/bash

# Install Amazon Linux Extras repositories
amazon-linux-extras install -y mariadb10.5 php7.4

# Install Apache, MariaDB, and PHP
yum install -y httpd mariadb-server php-gd

# Enable Apache
systemctl enable --now httpd

# Add ec2-user to the apache group
usermod -a -G apache ec2-user

# Set group ownership of /var/www
chown -R ec2-user:apache /var/www

# Change directory permissions
chmod 2775 /var/www && find /var/www -type d -exec chmod 2775 {} \;

# Change file permissions of /var/www
find /var/www -type f -exec chmod 0664 {} \;

# Enable TLS
yum install -y mod_ssl

# Run the script to generate a self-signed dummy certificate and key for testing
pushd /etc/pki/tls/certs > /dev/null 2>&1
./make-dummy-cert localhost.crt
popd > /dev/null 2>&1

# Comment out SSLCertificateKeyFile
sed -i 's/^SSLCertificateKeyFile/#SSLCertificateKeyFile/' /etc/httpd/conf.d/ssl.conf

# Enable MariaDB
systemctl enable --now mariadb

# Secure the database server
MYSQL_ROOT_PW=$(openssl rand -base64 12)
mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('${MYSQL_ROOT_PW}');FLUSH PRIVILEGES;" 
printf "${MYSQL_ROOT_PW}\n n\n n\n n\n y\n y\n y\n" | mysql_secure_installation
echo "***************************************" > install_script.out
echo "MySQL root password:   ${MYSQL_ROOT_PW}" >> install_script.out

# Configure WordPress Database  
wordpress_db_name="wp_db_name"
wordpress_db_user="wp_user_name"
wordpress_db_pass="$(openssl rand -base64 12)"

mysql -uroot -p${MYSQL_ROOT_PW} <<QUERY_INPUT  
CREATE DATABASE ${wordpress_db_name};
GRANT ALL PRIVILEGES ON ${wordpress_db_name}.* TO '${wordpress_db_user}'@'localhost' IDENTIFIED BY '${wordpress_db_pass}';
FLUSH PRIVILEGES;  
EXIT  
QUERY_INPUT

echo -e "\nWordpress db name:     ${wordpress_db_name}" >> install_script.out
echo "Wordpress db username: ${wordpress_db_user}" >> install_script.out
echo "Wordpress db password: ${wordpress_db_pass}" >> install_script.out
echo "***************************************" >> install_script.out

# Install Wordpress
wget https://wordpress.org/latest.tar.gz
tar xfz latest.tar.gz --strip-components 1 -C /var/www/html/
rm -rf latest.tar.gz
pushd /var/www/html > /dev/null 2>&1
cp wp-config-sample.php wp-config.php
sed -i "s|database_name_here|${wordpress_db_name}|" wp-config.php
sed -i "s|username_here|${wordpress_db_user}|" wp-config.php
sed -i "s|password_here|${wordpress_db_pass}|" wp-config.php
popd > /dev/null 2>&1

# Set permissions
chown -R apache:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0644 {} \;

# Restart Apache
systemctl restart httpd
