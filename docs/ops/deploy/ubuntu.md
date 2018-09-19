# Deploy production server on Ubuntu 14.04

### Overview

1. Setup deploy user
2. Install [Ruby](https://www.ruby-lang.org/en/)
3. Install [MySQL](http://www.mysql.com/)
4. Install [Redis](http://redis.io/)
5. Install [RabbitMQ](https://www.rabbitmq.com/)
6. Install [Bitcoind](https://en.bitcoin.it/wiki/Bitcoind)
7. Install [Nginx with Passenger](https://www.phusionpassenger.com/)
8. Install JavaScript Runtime
9. Install ImageMagick
10. Configure Peatio

### 1. Setup deploy user

Create (if it doesn’t exist) deploy user, and assign it to the sudo group:

    sudo adduser deploy
    sudo usermod -a -G sudo deploy

Re-login as deploy user

### 2. Install Ruby

Install the ruby build dependencies:

```shell
sudo apt-get install git curl zlib1g-dev build-essential \
  libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 \
  libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev
```

Install [rvm](https://rvm.io):

```shell
gpg --keyserver hkp://keys.gnupg.net \
    --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
                7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.8 --gems=rails
```

If you want to skip fetching documentation when installing gems,
do the following:

```shell
echo "gem: --no-ri --no-rdoc" > ~/.gemrc
```

### 3. Install MySQL

    sudo apt-get install mysql-server  mysql-client  libmysqlclient-dev

### 4. Install Redis

Be sure to install the latest stable Redis, as the package in the distro may be a bit old:

    sudo apt-add-repository -y ppa:rwky/redis
    sudo apt-get update
    sudo apt-get install redis-server

### 5. Install RabbitMQ

Please follow instructions here: https://www.rabbitmq.com/install-debian.html

    curl http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | sudo apt-key add -
    sudo apt-add-repository 'deb http://www.rabbitmq.com/debian/ trusty main'
    sudo apt-get update
    sudo apt-get install rabbitmq-server

    sudo rabbitmq-plugins enable rabbitmq_management
    sudo service rabbitmq-server restart
    wget http://localhost:15672/cli/rabbitmqadmin
    chmod +x rabbitmqadmin
    sudo mv rabbitmqadmin /usr/local/sbin

### 6. Install Bitcoind

    sudo add-apt-repository ppa:bitcoin/bitcoin
    sudo apt-get update
    sudo apt-get install bitcoind

**Configure**

    mkdir -p ~/.bitcoin
    touch ~/.bitcoin/bitcoin.conf
    vim ~/.bitcoin/bitcoin.conf

Insert the following lines into the bitcoin.conf, and replce with your username and password.

    server=1
    daemon=1

    # If run on the test network instead of the real bitcoin network
    testnet=1

    # You must set rpcuser and rpcpassword to secure the JSON-RPC api
    # Please make rpcpassword to something secure, `5gKAgrJv8CQr2CGUhjVbBFLSj29HnE6YGXvfykHJzS3k` for example.
    # Listen for JSON-RPC connections on <port> (default: 8332 or testnet: 18332)
    rpcuser=INVENT_A_UNIQUE_USERNAME
    rpcpassword=INVENT_A_UNIQUE_PASSWORD
    rpcport=18332

    # Notify when receiving coins
    walletnotify=/usr/local/sbin/rabbitmqadmin publish routing_key=peatio.deposit.coin payload='{"txid":"%s", "channel_key":"satoshi"}'

**Start bitcoin**

    bitcoind

### 7. Installing Nginx & Passenger

Install Phusion's PGP key to verify packages

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7

Add HTTPS support to APT

    sudo apt-get install apt-transport-https ca-certificates

Add the passenger repository. Note that this only works for Ubuntu 14.04. For other versions of Ubuntu, you have to add the appropriate repository according to Section 2.3.1 of this [link](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html).

    sudo add-apt-repository 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main'
    sudo apt-get update

Install nginx and passenger

    sudo apt-get install nginx-extras passenger

Next, we need to update the Nginx configuration to point Passenger to the version of Ruby that we're using. You'll want to open up /etc/nginx/nginx.conf in your favorite editor,

    sudo vim /etc/nginx/nginx.conf

find the following lines, and uncomment them:
     
    include /etc/nginx/passenger.conf;
    
open the passenger.conf file:

    sudo vim /etc/nginx/passenger.conf

update the second line to read:

    passenger_ruby /home/deploy/.rbenv/shims/ruby;

### 8. Install JavaScript Runtime

A JavaScript Runtime is needed for Asset Pipeline to work. Any runtime will do but Node.js is recommended.

    curl -sL https://deb.nodesource.com/setup | sudo bash -
    sudo apt-get install nodejs


### 9. Install ImageMagick

    sudo apt-get -y install imagemagick gsfonts


### 10. Setup production environment variable

    echo "export RAILS_ENV=production" >> ~/.bashrc
    source ~/.bashrc

##### Clone the Source

    mkdir -p ~/peatio
    git clone git://github.com/peatio/peatio.git ~/peatio/current
    cd peatio/current

    ＃ Install dependency gems
    bundle install --without development test --path vendor/bundle

##### Configure Peatio

**Prepare configure files**

    bin/init_config

**Setup bitcoind rpc endpoint**

    # replace username:password and port with the one you set in
    # username and password should only contain letters and numbers, do not use email as username
    # bitcoin.conf in previous step
    vim config/currencies.yml

**Config database settings**

    vim config/database.yml

    # Initialize the database and load the seed data
    bundle exec rake db:setup

**Precompile assets**

    bundle exec rake assets:precompile

**Run daemons**

Read how to deal with Peatio daemons at [Peatio daemons](https://github.com/rubykube/peatio/blob/master/docs/peatio/daemons.md).

**SSL Certificate setting**

For security reason, you must setup SSL Certificate for production environment, if your SSL Certificated is been configured, please change the following line at `config/environments/production.rb`

    config.force_ssl = true

**Passenger:**

    sudo rm /etc/nginx/sites-enabled/default
    sudo ln -s /home/deploy/peatio/current/config/nginx.conf /etc/nginx/conf.d/peatio.conf
    sudo service nginx restart
