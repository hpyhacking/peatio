# How to setup eth server for peatio

### What do you need?
- An instance with 4G of ram
- at least 100 G of hard disk
- Ubuntu 16.04

### Install geth

    sudo apt-get install software-properties-common
    sudo add-apt-repository -y ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install ethereum


### Run geth
copy the geth service file to /etc/systemd/system/geth.service
    
    sudo systemctl start geth
    sudo systemctl enable geth

### Install Nginx + fcgi


    sudo apt install nginx -y fcgiwrap
    sudo systemctl restart nginx

copy default file to /etc/nginx/sites-enabled/default

    sudo systemctl restart nginx


### cgi files

copy the cgi files to /var/www/html/cgi-bin and update total.cgi with your username

    sudo chown www-data:www-data -R /var/www/html/cgi-bin
    sudo chmod +x /var/www/html/cgi-bin/*

### Install filter service
copy total.js to /home/ubuntu

    sudo chown www-daya:www-data /home/ubuntu/total.js
don't forget to edit service.js with your url

    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
    sudo apt-get install -y nodejs
    cd ~/
    mkdir web3
    cd web3
    npm install axios web3 winston
copy service.js file to /home/ubuntu/web3

don't forget to update the username in filter.service
copy filter.service file to /etc/systemd/system/filter.service

    sudo systemctl start filter
    sudo systemctl enable filter

    sudo sh -c "echo 'www-data ALL=(ALL) NOPASSWD: /usr/sbin/service filter restart' >> /etc/sudoers"

You need to create at least one account and use it as a base account for withdrawals 

You need to edit app/models/worker/deposit_coin.rb ,deposit_coin_address.rb and withdraw_coin.rb

Add your ether server IP and your base account address 
Allow only peatio server to access ETH server on port 80
