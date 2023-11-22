#!/bin/bash
    
echo "Update with latest packages"
sudo apt update
    
echo "Install Apache"
sudo apt install apache2 git -y

echo "Install application"
cd /tmp
git clone https://github.com/kledsonhugo/app-static-site-ec2
cp /tmp/staticsite/*.html /var/www/html/