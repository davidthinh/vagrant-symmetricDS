#!/bin/bash
value=$( grep -ic "entry" /etc/hosts )
if [ $value -eq 0 ]
then
echo "
################ ceph-cookbook host entry ############
19.168.122.101 pcmk-1.clusterlabs.org pcmk-1
19.168.122.102 pcmk-2.clusterlabs.org pcmk-2
19.168.122.103 pcmk-3.clusterlabs.org pcmk-3
######################################################
" >> /etc/hosts
fi
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum remove -y  docker \
                  docker-common \
                  docker-engine
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo


sudo yum install  -y   docker-ce docker-ce-cli containerd.io

sudo  systemctl enable docker

sudo  systemctl start docker

sudo usermod -aG  docker vagrant

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
