#!/bin/bash

# Install Nginx if it is not already installed
if ! dpkg-query -W nginx; then
    apt-get update
    apt-get install -y nginx
fi

# Create the /data/ folder if it doesn't already exist
if [ ! -d "/data" ]; then
    mkdir /data
fi

# Create the necessary subfolders in /data/
mkdir -p /data/web_static/{releases,shared}
mkdir -p /data/web_static/releases/test

# Create a fake index.html file for testing
echo "Hello, World!" > /data/web_static/releases/test/index.html

# Create a symbolic link from /data/web_static/current to /data/web_static/releases/test/
if [ -L "/data/web_static/current" ]; then
    rm /data/web_static/current
fi
ln -s /data/web_static/releases/test/ /data/web_static/current

# Give ownership of the /data/ folder to the ubuntu user and group (recursively)
chown -R ubuntu:ubuntu /data

# Update the Nginx configuration to serve the content of /data/web_static/current/ to hbnb_static
sed -i "s/root \/var\/www\/html;/root \/data\/web_static\/current;/" /etc/nginx/sites-available/default
sed -i "s/index index.html index.htm index.nginx-debian.html;/index index.html;/" /etc/nginx/sites-available/default
sed -i "s/# location \/ {/location \/hbnb_static\/ {/" /etc/nginx/sites-available/default

# Restart Nginx
systemctl restart nginx

