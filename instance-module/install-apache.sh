#!/usr/bin/env sh

echo "Installing apache2 server"

sudo mkdir -p /var/www/html
sudo chown -R ubuntu:ubuntu /var/www
sudo apt update -y
sudo apt install apache2 -y
sudo /etc/init.d/apache2 start -y

echo "Finished installing apache2 server"

sleep 5