#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
#Prereqs for Hive and Cortex, not needed for Yeti
#Java
add-apt-repository ppa:openjdk-r/ppa
#Elastic
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key D88E42B4
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" |  tee -a /etc/apt/sources.list.d/elastic-5.x.list
apt-get update
apt-get install -y --no-install-recommends apt-transport-https openjdk-8-jre-headless elasticsearch python-pip python2.7-dev python3-pip python3-dev ssdeep libfuzzy-dev libfuzzy2 libimage-exiftool-perl libmagic1 build-essential git libssl-dev
echo 'network.host: 127.0.0.1' > /etc/elasticsearch/elasticsearch.yml
echo 'script.inline: on' >> /etc/elasticsearch/elasticsearch.yml
echo 'cluster.name: hive' >> /etc/elasticsearch/elasticsearch.yml
echo 'thread_pool.index.queue_size: 100000' >> /etc/elasticsearch/elasticsearch.yml
echo 'thread_pool.search.queue_size: 100000' >> /etc/elasticsearch/elasticsearch.yml
echo 'thread_pool.bulk.queue_size: 100000' >> /etc/elasticsearch/elasticsearch.yml
systemctl enable elasticsearch

####Add or remove sections as needed if you do not want a full install
#Hive
echo 'deb https://dl.bintray.com/cert-bdf/debian any main' |  tee -a /etc/apt/sources.list.d/thehive-project.list
apt-key adv --keyserver hkp://pgp.mit.edu --recv-key 562CBC1C
apt-get update
apt-get install -y --no-install-recommends thehive
systemctl enable thehive

#Cortex
echo 'deb https://dl.bintray.com/cert-bdf/debian any main' |  tee -a /etc/apt/sources.list.d/thehive-project.list
apt-key adv --keyserver hkp://pgp.mit.edu --recv-key 562CBC1C
apt-get update
apt-get install -y --no-install-recommends cortex
cd /etc/cortex/
git clone https://github.com/TheHive-Project/Cortex-Analyzers
for I in /etc/cortex/Cortex-Analyzers/analyzers/*/requirements.txt; do  -H pip2 install -r $I; done && \
for I in /etc/cortex/Cortex-Analyzers/analyzers/*/requirements.txt; do  -H pip3 install -r $I || true; done
 systemctl enable cortex

#Yeti
apt-get -y install build-essential git python-dev mongodb redis-server libxml2-dev libxslt-dev python-pip zlib1g-dev python-virtualenv wkhtmltopdf 
pip install setuptools wheel uwsgi
curl https://raw.githubusercontent.com/yeti-platform/yeti/master/extras/ubuntu_bootstrap.sh |  /bin/bash



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
