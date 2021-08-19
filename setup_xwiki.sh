#!/bin/sh

if [ ! -f /etc/provisioned ] ; then
  DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get install -y gnupg

  /usr/bin/wget -q "https://maven.xwiki.org/public.gpg" -O- | /usr/bin/apt-key add -
  /usr/bin/wget "https://maven.xwiki.org/lts/xwiki-lts.list" -P /etc/apt/sources.list.d/

  /usr/bin/apt-get update

  DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get install -y xwiki-tomcat9-mariadb

  /usr/bin/sed -i '/JAVA_OPTS/s/"$/ -Xms1024m -Xmx1024m"/' /etc/default/tomcat9

  /usr/bin/systemctl restart tomcat9

  touch /etc/provisioned
fi
