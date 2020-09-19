#!/usr/bin/env sh

echo "Installing wordpress cli tool"
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
echo "Finished installing wordpress cli tool"

sleep 5