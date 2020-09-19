#!/usr/bin/env sh

echo "Installing php and mysql client"

sudo apt-get install mysql-client -y
sudo apt install php libapache2-mod-php php-mysql -y

echo "Finsihed installing php and mysql client"

sleep 5