#!/bin/bash -f
# See [CISOfy Community](https://packages.cisofy.com/community/#debian-ubuntu)
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
apt-get install apt-transport-https
# would be nice to have switch statement to detect CODENAME
CODENAME="zesty"
echo "deb https://packages.cisofy.com/community/lynis/deb/ $CODENAME main" > /etc/apt/sources.list.d/cisofy-lynis.list
apt-get update
apt-get install lynis
