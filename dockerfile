FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    php \
    php-common \
    php-xml \
    php-mysql \
    php-gd \
    php-mbstring \
    php-tokenizer \
    php-json \
    php-bcmath \
    php-curl \
    php-zip \
    unzip


#Installing Puppet and Ansible:

RUN apt-get -y install puppet: Install Puppet
RUN apt-get install software-properties-common: Install required software properties
RUN apt-add-repository --yes --update ppa:ansible/ansible and apt-get install -y ansible

# Set the working directory
WORKDIR /var/www/html
RUN chown www-data:www-data /var/www/html; \
	chmod 777 /var/www/html

# Copy the .htaccess file to the container
COPY .htaccess .htaccess

# Copy your bash script to the container
COPY your_script.sh /usr/local/bin/

# Make your script executable
RUN chmod +x /usr/local/bin/slave.sh

# Expose port 80 to the host machine
EXPOSE 22
EXPOSE 80

# Start the necessary services and your script when the container runs
CMD ["apache2-foreground"]