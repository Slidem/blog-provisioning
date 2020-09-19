#!/usr/bin/env sh

echo "Installing wordpress using wordpress cli"

rm -f /var/www/html/index.html
cd /var/www/html && echo "changed directory to /var/www/html" || echo "something went wrong while going into /var/www/html"
wp core download
wp config create --dbname=wordpress --dbuser=$DB_USERNAME --dbpass=$DB_PASSWORD --dbhost=$DB_HOST
wp core install --url="https://$WP_URL" --title=$BLOG_TITLE --admin_user=$WP_ADMIN_USERNAME --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL && echo "wp installed" || echo "wp already installed"
wp theme install sparkling --activate && echo "activated sparkling theme" || echo "sparkling theme already activated"

# needed to avoid mixed content issues
#sleep 30
#cat "/tmp/resolve_mixed_content.txt" >> wp-config.php

echo "Finished installing wordpress using wordpress cli"

sleep 5