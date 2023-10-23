FROM ubuntu:22.04

FROM ubuntu:22.
ENV container docker
RUN  apt-get update -y && apt-get dist-upgrade -y

# Install system dependencies, you may not need all of these
RUN  apt-get install -y --no-install-recommends ssh RUN libffi-dev systemd openssh-client

# Needed to RUN  systemd
# VOLUME [ "/sys/fs/cgroup" ]
# Doesn't appear to be necessary? See comments

RUN  apt-get -y install puppet

# Add vagrant user and key for SSH
RUN  useradd --create-home -s /bin/bash vagrant
RUN  echo -n 'vagrant:vagrant' | chpasswd
RUN  echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant
RUN  chmod 440 /etc/sudoers.d/vagrant
RUN  mkdir -p /home/vagrant/.ssh
RUN  chmod 700 /home/vagrant/.ssh
RUN  echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > /home/vagrant/.ssh/authorized_keys
RUN  chmod 600 /home/vagrant/.ssh/authorized_keys
RUN  chown -R vagrant:vagrant /home/vagrant/.ssh
RUN  sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers
RUN  sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config

# Start SSH
RUN  mkdir /var/RUN /sshd
EXPOSE 22
RUN  /usr/sbin/sshd

RUN  apt-get update && apt-get install -y ansible sshpass python-apt

# Copy the necessary Ansible files to the container
# COPY inventory.ini /home/ansible/
# COPY lamp.yml /home/ansible/
# COPY cron.yml /home/ansible/

# Set the entrypoint to RUN  the Ansible playbook
ENTRYPOINT ["ansible-playbook", "/home/ansibly/lamp.yml", "-i", "/home/ansible/hosts.ini", "--ask-become-pass"]

# Start Systemd (systemctl)
CMD ["/lib/systemd/systemd"]

   # Install necessary packages
   RUN  apt-get update && apt-get install -y openssh-server

   # Create the Vagrant user and set up SSH access
# Install LAMP stack components
RUN apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql -1

# Start and enable Apache
RUN systemctl start apache2
RUN systemctl enable apache2

# Start and enable MySQL
RUN systemctl start mysql
RUN systemctl enable mysql

# Clone Laravel repository
RUN git clone https://github.com/laravel/laravel /var/www/html/laravel

# Create MySQL database
RUN mysql -e "CREATE DATABASE ansibyl_db;"
RUN mysql -e "CREATE USER 'ansibyl'@'localhost' IDENTIFIED BY 'ansibyl.cloud';"
RUN mysql -e "GRANT ALL PRIVILEGES ON ansibyl_db.* TO 'ansibyl'@'localhost';"
RUN mysql -e "FLUSH PRIVILEGES;"

# Configure Apache for Laravel
RUN cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/laravel.conf
RUN sed -i 's|/var/www/html|/var/www/html/laravel/public|g' /etc/apache2/sites-available/laravel.conf
RUN a2ensite laravel.conf
RUN systemctl restart apache2

# Set ServerName in Apache configuration
RUN bash -c 'echo "ServerName localhost" >> /etc/apache2/apache2.conf'

# Restart Apache
RUN service apache2 restart

# Install Composer
RUN  curl -sS https://getcomposer.org/installer | php
RUN  mv composer.phar /usr/local/bin/composer

# Install project dependencies
WORKDIR $WEB_ROOT
RUN  composer install

# Create privilege separation directory
RUN  mkdir -p /RUN /sshd

# Enable password-based authentication for SSH
RUN  sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose port 80 for Apache
EXPOSE 80

# Install an SSH server to keep the container running
RUN apt-get update && apt-get install -y openssh-server

# Configure the SSH server to run on startup
CMD ["/usr/sbin/sshd", "-D"]