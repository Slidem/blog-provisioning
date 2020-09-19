#!/usr/bin/env sh

echo "Installing offload media plugin for s3"

OFFLOAD_MEDIA_PLUGIN="amazon-s3-and-cloudfront.2.4.3.zip"

sudo curl -O "https://downloads.wordpress.org/plugin/$OFFLOAD_MEDIA_PLUGIN"
sudo apt install awscli -y
sudo apt install php-xml -y
sudo apt install php-curl -y
sudo chmod -R 777 /var/www/html/wp-content/
wp plugin install "./$OFFLOAD_MEDIA_PLUGIN" --path=/var/www/html --activate && echo "activated media offload plugin" || echo "offload media plugin already activated"
echo "Finished installing offload media plugin for s3"

echo "Removing downloaded zip file.."
rm "./$OFFLOAD_MEDIA_PLUGIN"

sleep 5