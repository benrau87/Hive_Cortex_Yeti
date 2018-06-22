#!/bin/bash
#Java
sudo add-apt-repository ppa:openjdk-r/ppa
#Elastic
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key D88E42B4
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
#Hive
echo 'deb https://dl.bintray.com/cert-bdf/debian any main' | sudo tee -a /etc/apt/sources.list.d/thehive-project.list
sudo apt-key adv --keyserver hkp://pgp.mit.edu --recv-key 562CBC1C
#Cortex
echo 'deb https://dl.bintray.com/cert-bdf/debian any main' | sudo tee -a /etc/apt/sources.list.d/thehive-project.list
sudo apt-key adv --keyserver hkp://pgp.mit.edu --recv-key 562CBC1C
#Install
sudo apt-get update
sudo apt-get install apt-transport-https git wget openjdk-8-jre-headless elasticsearch thehive cortex -y
sudo apt-get install -y --no-install-recommends python-pip python2.7-dev python3-pip python3-dev ssdeep libfuzzy-dev libfuzzy2 libimage-exiftool-perl libmagic1 build-essential git libssl-dev
cd /etc/cortex/
git clone https://github.com/TheHive-Project/Cortex-Analyzers
for I in /etc/cortex/Cortex-Analyzers/analyzers/*/requirements.txt; do sudo -H pip2 install -r $I; done && \
for I in /etc/cortex/Cortex-Analyzers/analyzers/*/requirements.txt; do sudo -H pip3 install -r $I || true; done

echo 'network.host: 127.0.0.1' > /etc/elasticsearch/elasticsearch.yml
echo 'script.inline: on' >> /etc/elasticsearch/elasticsearch.yml
echo 'cluster.name: hive' >> /etc/elasticsearch/elasticsearch.yml
echo 'thread_pool.index.queue_size: 100000' >> /etc/elasticsearch/elasticsearch.yml
echo 'thread_pool.search.queue_size: 100000' >> /etc/elasticsearch/elasticsearch.yml
echo 'thread_pool.bulk.queue_size: 100000' >> /etc/elasticsearch/elasticsearch.yml

sudo systemctl enable elasticsearch
sudo systemctl enable thehive
sudo systemctl enable cortex

apt-get -y install build-essential git python-dev mongodb redis-server libxml2-dev libxslt-dev zlib1g-dev python-virtualenv wkhtmltopdf 
pip install setuptools wheel 
curl https://raw.githubusercontent.com/yeti-platform/yeti/master/extras/ubuntu_bootstrap.sh | sudo /bin/bash
reboot

#After reboot
#/etc/thehive/conf
#add key
#add cortex url 
#/etc/cortex/conf 
#add key
#add play.modules.enabled += connectors.cortex.CortexConnector
#add cortex domain (http://localhost:9001)

#For Cortex, create org, add orgadmin, login as orgadmin, setup analyzers
#For The Hive, import reports
