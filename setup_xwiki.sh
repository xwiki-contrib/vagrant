#!/bin/sh

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg

wget -q "https://maven.xwiki.org/public.gpg" -O- | sudo apt-key add -
sudo wget "https://maven.xwiki.org/lts/xwiki-lts.list" -P /etc/apt/sources.list.d/

sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y xwiki-tomcat9-mariadb

sudo sed -i '/JAVA_OPTS/s/"$/ -Xms1024m -Xmx1024m"/' /etc/default/tomcat9

sudo systemctl restart tomcat9
