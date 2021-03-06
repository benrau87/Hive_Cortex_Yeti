#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
#Prereqs for Hive and Cortex, not needed for Yeti
#Java
add-apt-repository ppa:openjdk-r/ppa
#Elastic
# PGP key installation
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key D88E42B4
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
# Install https support for apt
apt update
sudo apt install -y apt-transport-https

# Elasticsearch installation
apt-get install -y --no-install-recommends apt-transport-https openjdk-8-jre-headless elasticsearch python-pip python2.7-dev python3-pip python3-dev ssdeep libfuzzy-dev libfuzzy2 libimage-exiftool-perl libmagic1 build-essential git libssl-dev
apt-get install -y --no-install-recommends python-pip python2.7-dev python3-pip python3-dev ssdeep libfuzzy-dev libfuzzy2 libimage-exiftool-perl libmagic1 build-essential git libssl-dev
pip install -U pip setuptools && sudo pip3 install -U pip setuptools


echo 'network.host: 127.0.0.1' > /etc/elasticsearch/elasticsearch.yml
echo 'script.inline: on' >> /etc/elasticsearch/elasticsearch.yml
echo 'cluster.name: hive' >> /etc/elasticsearch/elasticsearch.yml
echo 'thread_pool.index.queue_size: 100000' >> /etc/elasticsearch/elasticsearch.yml
echo 'thread_pool.search.queue_size: 100000' >> /etc/elasticsearch/elasticsearch.yml
echo 'thread_pool.bulk.queue_size: 100000' >> /etc/elasticsearch/elasticsearch.yml
systemctl enable elasticsearch.service

####Add or remove sections as needed if you do not want a full install
#Hive
echo 'deb https://dl.bintray.com/cert-bdf/debian any main' |  tee -a /etc/apt/sources.list.d/thehive-project.list
apt-key adv --keyserver hkp://pgp.mit.edu --recv-key 562CBC1C
apt-get update
apt-get install -y --allow-unauthenticated thehive

(cat << _EOF_
# Secret key
# ~~~~~
# The secret key is used to secure cryptographics functions.
# If you deploy your application to several instances be sure to use the same key!
play.crypto.secret="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)"
_EOF_
) | sudo tee -a /etc/thehive/application.conf

systemctl enable thehive

#Cortex
echo 'deb https://dl.bintray.com/thehive-project/debian-stable any main' | sudo tee -a /etc/apt/sources.list.d/thehive-project.list
sudo apt-key adv --keyserver hkp://pgp.mit.edu --recv-key 562CBC1C
sudo apt-get update
sudo apt-get -y install cortex

(cat << _EOF_
# Secret key
# ~~~~~
# The secret key is used to secure cryptographics functions.
# If you deploy your application to several instances be sure to use the same key!
play.http.secret.key="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)"
_EOF_

search.host = ['127.0.0.1:9300']
analyzer.path = ["/opt/Cortex-Analyzers/analyzers"]
play.modules.enabled += connectors.cortex.CortexConnector

) | sudo tee -a /etc/cortex/application.conf

cd /opt
git clone https://github.com/TheHive-Project/Cortex-Analyzers
for I in $(find Cortex-Analyzers -name 'requirements.txt'); do sudo -H pip2 install -r $I; done && \
for I in $(find Cortex-Analyzers -name 'requirements.txt'); do sudo -H pip3 install -r $I || true; done
systemctl enable cortex

#Yeti
#apt-get -y install build-essential git python-dev mongodb redis-server libxml2-dev libxslt-dev python-pip zlib1g-dev python-virtualenv wkhtmltopdf 
#pip install setuptools wheel uwsgi
#curl https://raw.githubusercontent.com/yeti-platform/yeti/master/extras/ubuntu_bootstrap.sh |  /bin/bash



#After reboot
#/etc/thehive/application.conf
#add cortex server (http://localhost:9001)
#add analyzer path in /etc/cortex/application.conf

#For Cortex, create org, add orgadmin, login as orgadmin, setup analyzers
#For The Hive, import reports
