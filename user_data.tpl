#!/bin/bash -x
# Log everything in /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

apt-get update -y
apt-get install -y nginx htop tcpdump curl
service nginx start