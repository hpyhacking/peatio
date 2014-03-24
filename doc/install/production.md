Overview
--------

The Peatio installation consists of setting up the following components:

1. Packages / Dependencies
2. Ruby
3. Database
4. Nginx
5. Redis
6. Bitcoind
7. Peatio


## 1. Packages / Dependencies

Create (if it doesn’t already exist) a deploy user, and assign it to the sudo group

    adduser deploy
    usermod -a -G sudo deploy
    logout # and re-login as deploy user

Make sure your system is up-to-date and install it.

    sudo apt-get update -y
    sudo apt-get upgrade -y

    # for Ubuntu <= 12.04
    sudo apt-get install python-software-properties

    # for Ubuntu >= 12.10
    sudo apt-get install software-properties-common

Install the required packages:

    sudo apt-get install -y curl qrencode libqrencode-dev git-core


## 2. Ruby

Installing [rbenv](https://github.com/sstephenson/rbenv) using a Installer

    curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash

    # update .bash_profile according to the instruction and insert the following lines
    vim ~/.bash_profile

    export RBENV_ROOT="${HOME}/.rbenv"
    if [ -d "${RBENV_ROOT}" ]; then
      export PATH="${RBENV_ROOT}/bin:${PATH}"
      eval "$(rbenv init -)"
    fi

    # reload the shell
    source ~/.bash_profile

    # install the dependencies (using the installer tool)
    rbenv bootstrap-ubuntu-12-04

    # install a Ruby version
    rbenv install 2.1.0
    rbenv rehash
    rbenv global 2.1.0

    # install bundler
    gem install bundler


## 3. Database

Peatio supports the following databases:

* MySQL (preferred)
* TODO: PostgreSQL

##### MySQL

    # Install the database packages
    sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev

    # Pick a database root password (can be anything), type it and press enter
    # Retype the database root password and press enter

    # Secure your installation.
    sudo mysql_secure_installation

    # Login to MySQL
    mysql -u root -p

    # Type the database root password

    # Create a user for Peatio
    # change $password in the command below to a real password you pick
    CREATE USER 'peatio'@'localhost' IDENTIFIED BY '$password';

    # Create the PeatioPeatio production database
    CREATE DATABASE IF NOT EXISTS `peatio_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;

    # Grant the Peatio user necessary permissions on the table.
    GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `peatio_production`.* TO 'peatio'@'localhost';

    # Quit the database session
    mysql> \q


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

    deb http://nginx.org/packages/ubuntu/ precise nginx
    deb-src http://nginx.org/packages/ubuntu/ precise nginx

    # install nginx
    sudo apt-get update && sudo apt-get -y install nginx

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

##### Start Bitcoind

    bitcoind


## 7. Peatio

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

**Resque:**

    rake environment resque:matching
    RAILS_ENV=production rake environment resque:work QUEUE=coin,examine PIDFILE=/home/deploy/www/peatio/tmp/pids/resque.pid &

**Liability Proof**

    # Add this rake task to your crontab so it runs regularly
    RAILS_ENV=production rake solvency:liability_proof

