# Docker image to use with Vagrant
# Aims to be as similar to normal Vagrant usage as possible

FROM ubuntu:22.04

ENV container docker
RUN  apt-get update -y && apt-get dist-upgrade -y
RUN apt-get update -y && apt-get dist-upgrade -y
RUN apt-get install -y --no-install-recommends ssh libffi-dev systemd openssh-client

COPY lamp_stack.sh /lamp_stack.sh

RUN chmod +x /lamp_stack.sh

RUN  apt-get -y install puppet

#install ansible and dependencies
RUN apt-get install software-properties-common
RUN apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible
RUN apt-get update
RUN apt-get install ansible

RUN apt-get install -y git

# Clean up the package cache.
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the working directory to /ansible. You can change this to your preference.
WORKDIR /ansible

# Add user "ansibyl" and key for SSH
RUN  useradd --create-home -s /bin/bash ansibyl
RUN  echo 'ansibyl:ansibyl' | chpasswd
RUN  echo 'ansibyl ALL = NOPASSWD: ALL' > /etc/sudoers.d/ansibyl
RUN  chmod 440 /etc/sudoers.d/ansibyl
RUN  mkdir -p /home/ansibyl/.ssh
RUN  chmod 700 /home/ansibyl/.ssh
RUN  echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > /home/ansibyl/.ssh/authorized_keys
RUN  chmod 600 /home/ansibyl/.ssh/authorized_keys
RUN  chown -R ansibyl:ansibyl /home/ansibyl/.ssh
RUN  sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers
RUN  sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config


RUN  apt-get update && apt-get install -y ansible sshpass python-apt

# # copy the necessary Ansible files to the container
# COPY hosts.ini /home/ansible/
# COPY lamp_dock.yaml /home/ansible/
# COPY cron.yml /home/ansible/

# Set the entrypoint to RUN  the Ansible playbook
ENTRYPOINT ["ansible-playbook", "/home/ansible/lamp_dock.yaml", "-i", "/home/ansible/hosts.ini", "--ask-become-pass"]

# Start Configure OpenSSH server
RUN apt-get update && apt-get install -y openssh-server

# Configure OpenSSH server
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#StrictModes yes/StrictModes no/' /etc/ssh/sshd_config


EXPOSE 22

RUN  /usr/sbin/sshd

# Start Systemd (systemctl)
CMD ["/lib/systemd/systemd"]
