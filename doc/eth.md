# How to setup eth server for peatio

### What do you need?
- An instance with 4G of ram
- at least 100 G of hard disk

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

    sudo apt install nginx fcgiwrap
copy default file to /etc/nginx/sites-enabled/default

    sudo systemctl restart nginx

### cgi files

copy the cgi files to /var/www/html

    sudo chmod www-data:www-data -R /var/www/html

### Install filter service
don't forget to edit service.js with your url

    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
    sudo apt-get install -y nodejs
    adduser ubuntu
    sudo su ubuntu
    cd ~/
    mkdir web3
    cd web3
    npm install axios
    npm install web3
    npm install winston
copy service.js file to /home/ubuntu/web3

copy filter service file to /etc/systemd/system/geth.service

    sudo systemctl start geth
    sudo systemctl enable geth

    sudo sh -c "echo "www-data ALL=(ALL) NOPASSWD: /usr/sbin/service filter restart >> /etc/sudoers

