#!/bin/    ```  

sudo apt-get update 
sudo apt-get upgrade 
sudo apt-get install zip unzip 
sudo apt-get apache2
sudo service apache2 restart
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
sudo apt install mysql-server -y
sudo mysql_secure_installation
sudo mysql
## mysql comfiguration
    # CREATE USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'YOUR_PASSWORD';
        # FLUSH PRIVILEGES;
     #quit

     mysql -u root -p
     CREATE DATABASE your_database_name;

sudo apt install curl -y
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer 
sudo chmod +x /usr/local/bin/composer
php -v mysql --version composer -V

#### copy your project files from your computer to server
scp -i your_key.pem your_project.zip ubuntu@your_ip -v
sudo unzip your_project.zip -d /var/www/html/

#### change your project files ownership to server
sudo chown www-data:www-data -R /var/www/html/your_project

sudo a2enmod proxy
sudo a2enmod proxy_http

### Create Virtual Host Configuration
sudo nano /etc/apache2/sites-available/your_project.conf
     <VirtualHost *.80>
     ServerName YOUR_DOMAIN_ADDRESS
     DocumentRoot /var/www/html/your_project
    <Directory /var/www/html/your_project/ >
     AllowOverride All
    Require all granted
    Allow from all
    </Directory>
    </VirtualHost>

### Enable Virtual Host Your Just Made
 sudo a2ensite your_project.conf



 sudo nano /var/www/html/.htaccess

 cd /var/www/html/your_project/
 composer install

sudo chmod 777 -R /var/www/html

sudo chown -R www-data storage
sudo chown -R www-data storage/framework
sudo chmod g+w -R storage
sudo chmod g+w -R storage/framework
sudo chmod g+w -R storage/framework/sessions/
sudo chmod g+w -R storage/logs/

php artisan migrate --seed

 php artisan serve


sudo service apache2 restart

sudo nano /var/www/html/your-project/storage/logs/laravel.log