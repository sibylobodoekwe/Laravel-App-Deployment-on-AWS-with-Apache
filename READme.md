# Laravel App Deployment on AWS with Apache

### This README provides instructions for deploying a Laravel application on an AWS EC2 instance using Apache as the web server. Please follow these Steps carefully to ensure a successful deployment.

## Prerequisites

### Before you begin, make sure you have the following prerequisites:

### - An AWS account with an EC2 instance set up.
### - An SSH key pair for accessing your EC2 instance.
### - Basic knowledge of AWS and Laravel.



#  SSH into your EC2 instance

### Replace `your_key.pem` and `your_ip` with your SSH key and instance's public IP address.

```
ssh -i ~/path/to/your_key.pem ubuntu@your_ip

```

# Update and Upgrade Packages

### Update and upgrade the package list on your `EC2` instance.

```  
sudo apt-get update
sudo apt-get upgrade

```

 # Install Required Packages

### Install essential packages, including `Apache`, `PHP`, `MySQL`, `Composer`, and other dependencies.


```  
sudo apt-get install zip unzip apache2 phpmyadmin php-mbstring php-zip php-gd php-json php-curl mysql-server curl -y

```

 # Secure MySQL Installation

### Run the `MySQL` secure installation script and set a secure password for the root user.


```  
sudo mysql_secure_installation

```

 # Create a MySQL Database

### Log in to MySQL and create a database for your Laravel application.

```  
sudo mysql -u root -p

```

# Enter your MySQL root password

```
CREATE DATABASE your_database_name;

```

 # Install Composer

### Install Composer globally on your server.

```  
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
php -v
composer -V

```

 # Copy Project Files to Server


### Copy your Laravel project files from your local computer to the server using `SCP`.

```  

scp -i your_key.pem your_project.zip ubuntu@your_ip:/home/ubuntu/
sudo unzip /home/ubuntu/your_project.zip -d /var/www/html/

```

 # Set Ownership

### Change ownership of the project files to the web server user (www-data).

```  

sudo chown www-data:www-data -R /var/www/html/your_project

```

 # Enable Apache Modules

Enable Apache proxy and `proxy_http` modules.

```  

sudo a2enmod proxy
sudo a2enmod proxy_http

```

 # Create Virtual Host Configuration

### Create a Virtual Host configuration file for your Laravel application.

```  

sudo nano /etc/apache2/sites-available/your_project.conf

```

### Add the following configuration, replacing `YOUR_DOMAIN_ADDRESS` with your domain or IP address:

apache
```

<VirtualHost *:80>
    ServerName YOUR_DOMAIN_ADDRESS
    DocumentRoot /var/www/html/your_project

    <Directory /var/www/html/your_project/>
        AllowOverride All
        Require all granted
        Allow from all
    </Directory>
</VirtualHost>
```

### Save and exit the text editor.

 # Enable Virtual Host

### Enable the virtual host you just created.

```  
sudo a2ensite your_project.conf

```
Now reload Apache web server, i prefer this to a full restart because it doesn't interrupt ongoing connections to your web server.

```
sudo systemctl reload apache2
```

 # Install Composer Dependencies

### Navigate to your project directory and install Composer dependencies.

```  
cd /var/www/html/your_project/
composer install

```

 # Permissions

### Set permissions and ownership for Laravel storage directories.

```  
sudo chmod 777 -R /var/www/html/your_project
sudo chown -R www-data:www-data /var/www/html/your_project/storage
sudo chmod -R g+w /var/www/html/your_project/storage
sudo chmod -R g+w /var/www/html/your_project/storage/framework
sudo chmod -R g+w /var/www/html/your_project/storage/framework/sessions/
sudo chmod -R g+w /var/www/html/your_project/storage/logs/

```

 # Database Migration and Seed

### Run Laravel database migration and seeding.

```  

php artisan migrate --seed

```

 # Step 16: Start the Application

### Start the Laravel application using Artisan's built-in server.

```  

php artisan serve

```

 # Restart Apache

### Restart Apache to apply the changes.

```  

sudo service apache2 restart

```

 # View Logs

### If you encounter any issues, you can check the Laravel logs for debugging.

```  

sudo nano /var/www/html/your-project/storage/logs/laravel.log

```

### That's it! Your Laravel application should now be deployed and accessible via your domain or IP address. If you face any issues during the deployment process, refer to the logs for troubleshooting.

### Feel free to modify these steps according to your specific project requirements. Good luck with your Laravel app deployment!