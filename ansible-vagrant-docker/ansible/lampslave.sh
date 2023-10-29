# updating & upgrading the server
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install apt-utils

# clone laravel application and dependencies
mkdir /var/www/html/laravel && cd /var/www/html/laravel
cd /var/www/html && sudo git clone https://github.com/laravel/laravel.git
cd /var/www/html/laravel && composer install --no-dev < /dev/null
sudo chown -r www-data:www-data /var/www/html/laravel
sudo chmod -r 775 /var/www/html/laravel
sudo chmod -r 775 /var/www/html/laravel/storage
sudo chmod -r 775 /var/www/html/laravel/bootstrap/cache
cd /var/www/html/laravel && sudo cp .env.example .env
php artisan key:generate

# installation of LAMP stack
sudo apt-get install apache2 -y
sudo apt-get install mysql-server -y
sudo apt install ansible -y
sudo add-apt-repository ppa:ondrej/php
sudo apt-get install libapache2-mod-php php php-common php-xml php-mysql php-gd php-mbstring php-tokenizer php-json php-bcmath php-curl php-zip
sudo apt-get install cron

# configuration of PHP
sudo sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/apache2/php.ini
sudo systemctl restart apache2

# install composer
sudo apt install curl -y 
sudo curl -ss https://getcomposer.org/installer | php 
sudo mv composer.phar /usr/local/bin/composer 
composer --version < /dev/null

# configuration of Apache2
cat <<EOF | sudo tee /etc/apache2/sites-available/laravel.conf
<virtualhost *:80>
    serveradmin webmaster@example.com
    servername localhost
    documentroot /var/www/html/laravel/public
    <directory /var/www/html/laravel>
        options indexes multiviews followsymlinks
        allowoverride all
        require all granted
    </directory>
    errorlog \${apache_log_dir}/error.log
    customlog \${apache_log_dir}/access.log combined
</virtualhost>
EOF

sudo a2enmod rewrite 
sudo a2ensite laravel.conf
sudo systemctl restart apache2

# configuring MySQL: creating user and database
sudo mysql -e "create database ansibyldb;"
sudo mysql -e "create user 'ansibyl'@'localhost' identified by 'password';"
sudo mysql -e "grant all privileges on ansibyldb.* to 'ansibyl'@'localhost';"
sudo mysql -e "flush privileges;"

# configure .env file
sudo sed -i 's/db_database=laravel/db_database=ansibyldb/' /var/www/html/laravel/.env
sudo sed -i 's/db_username=root/db_username=ansibyl/' /var/www/html/laravel/.env
sudo sed -i 's/db_password=/db_password=password/' /var/www/html/laravel/.env

# cache config
php artisan config:cache
cd /var/www/html/laravel
php artisan migrate

# set servername in Apache configuration
sudo bash -c 'echo "servername 192.168.33.20" >> /etc/apache2/apache2.conf'

# restart Apache
sudo service apache2 restart

# display deployment completion message
echo "lamp stack deployed successfully."
