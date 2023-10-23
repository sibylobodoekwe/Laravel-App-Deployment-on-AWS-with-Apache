Project: Automating LAMP Stack Deployment
Objective
The goal of this project is to automate the provisioning of two Ubuntu-based servers, "Master" and "Slave," using Vagrant. We will create a reusable and readable bash script for deploying a LAMP (Linux, Apache, MySQL, PHP) stack on the Master node. Additionally, we will use Ansible to execute the script on the Slave node and verify the accessibility of a PHP application deployed via the VM's IP address. Finally, we will create a cron job to check the server's uptime daily.

Prerequisites

Before proceeding with the project, make sure you have the following prerequisites in place:

Dockerized LAMP Stack Deployment
i'm using docker as my deploy container. it's great for its flexibility and compatibility with different system architectures, including ARM64 silicon. You can create container images for your applications and run them without the need for traditional virtualization tools like VirtualBox or VMware etc.

Dockerfile
Building the Docker Image
We start with a Dockerfile that defines the steps to create a Docker image with the necessary components for a LAMP stack. You can build this image by executing the following commands:

```
docker build -t lamp-stack .
Dockerfile Commands
FROM ubuntu:22.04: This line sets the base image to Ubuntu 22.04.

ENV container docker: Setting the container environment variable.

Package Updates and Installations:

apt-get update and apt-get dist-upgrade: Update and upgrade system packages.
apt-get install -y --no-install-recommends ssh libffi-dev systemd openssh-client: Install required packages.
Copying the Bash Script:

COPY lamp_stack.sh /lamp_stack.sh: Copy the deployment script to the container.
Setting Permissions:

RUN chmod +x /lamp_stack.sh: Make the script executable.
Installing Puppet and Ansible:

RUN apt-get -y install puppet: Install Puppet.
RUN apt-get install software-properties-common: Install required software properties.
RUN apt-add-repository --yes --update ppa:ansible/ansible and apt-get install -y ansible: Install Ansible and its dependencies.
Install Git:

RUN apt-get install -y git: Install Git.
Cleaning Up:

RUN apt-get clean and other commands are used to clean up the package cache and remove unnecessary files.
Setting up SSH:

Configuration for SSH key authentication and passwordless login.
Starting SSH:

RUN /usr/sbin/sshd: Start the SSH server.
Starting Systemd:

CMD ["/lib/systemd/systemd"]: Set the entry point to run Systemd.
Creating Docker Containers
Now that we have built the Docker image, we can create Docker containers from it. You can start two containers, "master" and "slave," as follows:

```
docker run -d --name master -v $(pwd)/provision:/home/ansible/provision -v /home/ansible/home/ansible/ansible lamp-stack
docker run -d --name slave -v $(pwd)/provision:/home/ansible/provision -v ansible:/home/ansible/ansible lamp-stack
--name master and --name slave give the containers their names.
-v $(pwd)/provision:/home/ansible/provision and -v ansible:/home/ansible/ansible mount volumes to share Ansible playbooks and data.
Docker Compose
To simplify the deployment process and manage multiple containers, you can use Docker Compose. The docker-compose.yml file defines the services, volumes, and other settings for the containers.

Starting Containers with Docker Compose
To start the containers using Docker Compose, run the following command:

```
docker-compose up -d
```
This command reads the docker-compose.yml file and starts the defined services.

Basically, using Docker and Docker Compose, you can deploy a LAMP stack efficiently and manage your containers with ease. This approach is particularly advantageous for systems with ARM64 silicon, as Docker supports various hardware architectures. Docker allows you to create reproducible environments and streamline the deployment process for your applications.


Creating the Vagrantfile
```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu2204"

  config.vm.define "master" do |master|
    master.vm.provider "docker" do |d|
      d.remains_running = true
      d.ports = ["80:80"]
    end

    master.vm.hostname = "master"
    master.vm.network "private_network", ip: "192.168.33.10"
    master.vm.network :forwarded_port, guest: 22, host: 2224
  end

  config.vm.define "slave" do |slave|
    slave.vm.provider "docker" do |d|
      d.remains_running = true
      d.ports = ["80:8080"]
    end

    slave.vm.hostname = "slave"
    slave.vm.network "private_network", ip: "192.168.33.14"
    slave.vm.network :forwarded_port, guest: 22, host: 2226
  end
end
Get the Servers up 
```
vagrant up
Creating User "ansibyl"
On the Master node:

```
vagrant ssh master -c "sudo useradd -m -s /bin/bash ansibyl"
vagrant ssh master -c "sudo usermod -aG sudo ansibyl"
vagrant ssh master -c "echo 'ansibyl:password' | sudo chpasswd"
On the Slave node:

```
vagrant ssh slave -c "sudo useradd -m -s /bin/bash ansibyl"
vagrant ssh slave -c "sudo usermod -aG sudo ansibyl"
vagrant ssh slave -c "echo 'ansibyl:password' | sudo chpasswd"
Creating Passwordless SSH between slave and master
```
# SSH key setup on Master
vagrant ssh master -c "sudo -u ansibyl ssh-keygen -t rsa"
vagrant ssh master -c "echo '192.168.33.14 slave' | sudo tee -a /etc/hosts"
vagrant ssh master -c "sudo -u ansibyl ssh-copy-id ansibyl@192.168.33.14"

# SSH key setup on Slave
vagrant ssh slave -c "sudo -u ansibyl ssh-keygen -t rsa"
vagrant ssh slave -c "echo '192.168.33.10 master' | sudo tee -a /etc/hosts"
vagrant ssh slave -c "sudo -u ansibyl ssh-copy-id ansibyl@192.168.33.10"
Confirming Passwordless SSH
Alt text

Creating Directories
On both nodes:

```
vagrant ssh master -c 'sudo -u ansibyl mkdir -p /home/ansibyl/scripts /home/ansibyl/logs'
vagrant ssh slave -c 'sudo -u ansibyl mkdir -p /home/ansibyl/scripts /home/ansibyl/logs'
Appending Shebang
On the Master node:

```
vagrant ssh master
sudo su ansibyl
cd ../ansibyl/scripts/
echo '#!/bin/bash' > lamp_stack.sh
Writing the Deploy LAMP Stack Script
```
# Deploy LAMP stack script
deploy_script_content="
# Update package information
sudo apt-get update

# Upgrade installed packages
sudo apt-get upgrade -y

# Install LAMP stack components
sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql git

# Start and enable Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Start and enable MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Clone Laravel repository
git clone https://github.com/laravel/laravel /var/www/html/laravel

# Create MySQL database
sudo mysql -e \"CREATE DATABASE ansibyl_db;\"
sudo mysql -e \"CREATE USER 'ansibyl'@'localhost' IDENTIFIED BY 'ansibyl.cloud';\"
sudo mysql -e \"GRANT ALL PRIVILEGES ON ansibyl_db.* TO 'ansibyl'@'localhost';\"
sudo mysql -e \"FLUSH PRIVILEGES;\"

# Configure Apache for Laravel
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/laravel.conf
sudo sed -i 's|/var/www/html|/var/www/html/laravel/public|g' /etc/apache2/sites-available/laravel.conf
sudo a2ensite laravel.conf
sudo systemctl restart apache2

# Set ServerName in Apache configuration
sudo bash -c 'echo \"ServerName localhost\" >> /etc/apache2/apache2.conf'

# Restart Apache
sudo service apache2 restart

# Display deployment completion message
echo \"LAMP stack deployed successfully.\"
"

# Append deploy script content to lamp_stack.sh
vagrant ssh master -c 'sudo -u ansibyl tee -a /home/ansibyl/scripts/lamp_stack.sh' <<< "$deploy_script_content"
Copying lamp_stack.sh to Slave Node
```
# Copy lamp_stack.sh to the Slave node
vagrant ssh master -c "sudo -u ansibyl scp -o StrictHostKeyChecking=no /home/ansibyl/scripts/lamp_stack.sh ansibyl@slave:/home/ansibyl/scripts/"
Installing Ansible on Slave Node
```
# Install Ansible on the Slave node
vagrant ssh slave -c "sudo -u ansibyl sudo apt-get update && sudo apt-get install ansible -y"
Creating Ansible Inventory
```
# Ansible inventory setup
inventory_content="
# inventory.ini
[master]
master ansible_ssh_host=192.168.33.10 ansible_ssh_user=ansibyl

[slave]
slave ansible_ssh_host=192.168.33.14 ansible_ssh_user=ansibyl

[all:vars]
ansible_python_interpreter=/usr/bin/python3
"

# Append inventory