#!/bin/bash

# update package information
vagrant ssh master -c "sudo apt-get update"

# user setup on master
vagrant ssh master -c "sudo useradd -m -s /bin/bash ansibyl"
vagrant ssh master -c "sudo usermod -ag sudo ansibyl"
vagrant ssh master -c "echo 'ansibyl:password' | sudo chpasswd"

# user setup on slave
vagrant ssh slave -c "sudo useradd -m -s /bin/bash ansibyl"
vagrant ssh slave -c "sudo usermod -ag sudo ansibyl"
vagrant ssh slave -c "echo 'ansibyl:password' | sudo chpasswd"

# generate ssh key on master
vagrant ssh master -c "sudo -u ansibyl ssh-keygen -t rsa"

# update /etc/hosts on master to include slave
vagrant ssh master -c "echo '192.168.33.25 slave' | sudo tee -a /etc/hosts"

# copy public key from master to slave
vagrant ssh master -c "sudo -u ansibyl ssh-copy-id ansibyl@192.168.33.25"

# set proper permissions for the 'ansibyl' user's .ssh directory and key files on master
vagrant ssh master -c "sudo chown -r ansibyl:ansibyl /home/ansibyl/.ssh && sudo chmod 700 /home/ansibyl/.ssh && sudo chmod 600 /home/ansibyl/.ssh/id_rsa"

# generate ssh key on slave
vagrant ssh slave -c "sudo -u ansibyl ssh-keygen -t rsa"

# update /etc/hosts on slave to include master
vagrant ssh slave -c "echo '192.168.33.20 master' | sudo tee -a /etc/hosts"

# copy public key from slave to master
vagrant ssh slave -c "sudo -u ansibyl ssh-copy-id ansibyl@192.168.33.20"

# set proper permissions for the 'ansibyl' user's .ssh directory and key files on slave
vagrant ssh slave -c "sudo chown -r ansibyl:ansibyl /home/ansibyl/.ssh && sudo chmod 700 /home/ansibyl/.ssh && sudo chmod 600 /home/ansibyl/.ssh/id_rsa"

# create the 'ansible' directory on both nodes
vagrant ssh master -c "sudo -u ansibyl mkdir -p /home/ansibyl/scripts /home/ansibyl/logs"
vagrant ssh slave -c "sudo -u ansibyl mkdir -p /home/ansibyl/scripts /home/ansibyl/logs"

# append shebang and create a deployment script called 'master.sh' on the master node
vagrant ssh master -c "sudo su ansibyl -c 'echo \"#!/bin/bash\" > /home/ansibyl/scripts/slave.sh'"

# copy 'master.sh' to the slave node
vagrant ssh master -c "sudo -u ansibyl scp /home/ansibyl/scripts/master.sh ansibyl@slave:/home/ansibyl/scripts/"

# install ansible on the slave node
vagrant ssh slave -c "sudo -u ansibyl sudo apt-get update && sudo apt-get install ansible -y"

