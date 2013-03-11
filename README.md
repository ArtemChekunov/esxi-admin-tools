esxi-admin-tools
================

Repository with collection tools for VMware ESX/ESXi 

# How to install ESXi Monitoro on Debian wheezy

sudo apt-get install nginx uwsgi uwsgi-plugin-cgi gawk sed -y

git clone git://github.com/sc0rp1us/esxi-admin-tools.git esxi-admin-tools

sudo mkdir /var/www/.ssh/

sudo chown -R www-data:www-data esxi-admin-tools/{configs,.ssh,tmp} /var/www/.ssh/

sudo chmod 700 esxi-admin-tools/.ssh /var/www/.ssh/

sudo chmod 600 esxi-admin-tools/.ssh/* /var/www/.ssh/*

# Go to esxi-admin-tools/configs and create config files
# go to esxi-admin-tools/.ssh and save private keys for esxi

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.origin

sudo cp distr.example.configs/debian/etc/nginx/sites-available/default /etc/nginx/sites-available/default

sudo cp distr.example.configs/debian/etc/uwsgi/apps-available/bash-cgi.xml /etc/uwsgi/apps-available/

sudo ln -s /etc/uwsgi/apps-available/bash-cgi.xml /etc/uwsgi/apps-enabled/

sudo /etc/init.d/nginx restart

sudo /etc/init.d/uwsgi restart

# Go to http://you_ip_addr
