Overview
--------

The Peatio installation consists of setting up the following components:

1. Preparation
2. Ruby
3. Database
4. Nginx
5. Redis
6. Bitcoind
7. RabbitMQ
8. Peatio


## 1. Preparation

Create (if it doesn’t already exist) a deploy user, and assign it to the sudo group

    adduser deploy
    usermod -a -G sudo deploy
    logout # and re-login as deploy user

Make sure your system is up-to-date.

    sudo apt-get update
    sudo apt-get upgrade

## 2. Ruby

Installing [rbenv](https://github.com/sstephenson/rbenv) using a Installer

    sudo apt-get install git-core curl zlib1g-dev build-essential \
                         libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 \
                         libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties

    cd
    git clone git://github.com/sstephenson/rbenv.git .rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL

    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL

    rbenv install 2.1.2
    rbenv global 2.1.2
    ruby -v

    echo "gem: --no-ri --no-rdoc" > ~/.gemrc

    gem install bundler


## 3. Database

Peatio supports the following databases:

* MariaDB (MySQL)

##### MariaDB

Please follow instructions here:  https://downloads.mariadb.org/mariadb/repositories/#mirror=nus&distro=Ubuntu&distro_release=trusty&version=10.0

    sudo apt-get install mariadb-server mariadb-client libmariadbclient-dev

## 4. Redis

Be sure to install the latest stable Redis, as the package in the distro may be a bit old:

    sudo apt-add-repository -y ppa:rwky/redis
    sudo apt-get update && sudo apt-get install -y redis-server


## 5. Nginx

We recommend the latest version of nginx (we like the new and shiny). To install on Ubuntu:

    # Remove any existing versions of nginx
    sudo apt-get remove '^nginx.*$'

    # Add nginx key
    curl http://nginx.org/keys/nginx_signing.key | sudo apt-key add -

    # Setup a sources.list.d file for the nginx repository and insert the following lines
    sudo vim /etc/apt/sources.list

    deb http://nginx.org/packages/ubuntu/ trusty nginx
    deb-src http://nginx.org/packages/ubuntu/ trusty nginx

    # install nginx
    sudo apt-get update
    sudo apt-get install nginx

## 6. Bitcoind

##### install bitcoind

    sudo add-apt-repository ppa:bitcoin/bitcoin
    sudo apt-get update && sudo apt-get install -y bitcoind

By default, bitcoind will look for a file name "bitcoin.conf" in the bitcoin data directory `$HOME/.bitcoin/`.

    mkdir ~/.bitcoin
    vim ~/.bitcoin/bitcoin.conf

    # Insert the following code in it, and replce with your username and password
    server=1
    daemon=1
    rpcusername=INVENT_A_UNIQUE_USERNAME
    rpcpassword=INVENT_A_UNIQUE_PASSWORD

    # If run on the test network instead of the real bitcoin network
    testnet=1

    # Notify when receiving coins
    walletnotify=/usr/local/sbin/rabbitmqadmin publish routing_key=peatio.deposit.coin payload='{"txid":"%s", "channel_key":"satoshi"}'

##### Start Bitcoind

    bitcoind

## 7. RabbitMQ

Please follow instructions here: https://www.rabbitmq.com/install-debian.html

## 8. Peatio

##### Clone the Source

    # install peatio to ~/www/peatio
    mkdir ~/www
    cd ~/www
    git clone git@github.com:peatio/peatio.git

    # Go to peatio dir
    cd ~/www/peatio

    ＃ Install necessary gems
    bundle install --without development test


##### Configure Peatio and run

**Database:**

    vim config/database.yml

    # Sample of database.yml
    production:
      adapter: mysql2
      database: peatio_production
      username: peatio
      password: your_password_of_db

    # Initialize the database
    RAILS_ENV=production bundle exec rake db:setup

**E-mail:**

    TODO

**Nginx:**

    sudo mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.disabled
    sudo cp /home/deploy/www/peatio/config/nginx.conf /etc/nginx/conf.d/peatio.conf
    sudo service nginx restart

**Unicorn:**

    RAILS_ENV=production bundle exec rake assets:precompile
    bundle exec unicorn_rails -E production -c config/unicorn.rb -D

**Liability Proof**

    # Add this rake task to your crontab so it runs regularly
    RAILS_ENV=production rake solvency:liability_proof

