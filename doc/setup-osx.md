Setup on Mac OS X 10.9 Mavericks
-------------------------------------

### Overview

1. Install [Homebrew](http://brew.sh/)
2. Install [Ruby](https://www.ruby-lang.org/en/)
3. Install [MariaDB](https://mariadb.org/) (A community developed fork of MySQL)
4. Install [Redis](http://redis.io/)
5. Install [RabbitMQ](https://www.rabbitmq.com/)
6. Install [Bitcoind](https://en.bitcoin.it/wiki/Bitcoind)
7. Configure Peatio

### 1. Install Homebrew

    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

### 2. Install Ruby

    brew install rbenv ruby-build

Add rbenv to bash so that it loads every time you open a terminal

    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
    source ~/.bash_profile

Install Ruby 2.1.2 and set it as the default version

    rbenv install 2.1.2
    rbenv global 2.1.2

    ruby -v

Install bundler

    echo "gem: --no-ri --no-rdoc" > ~/.gemrc
    gem install bundler
    rbenv rehash

### 3. Install MariaDB

    brew install mariadb

### 4. Install Redis

    brew install redis

### 5. install RabbitMQ

    brew install rabbitmq

### 6. install Bitcoind

Download and Install [Bitcoin Core](http://bitcoin.org/en/download)

    mkdir -p ~/Library/Application\ Support/Bitcoin
    touch ~/Library/Application\ Support/Bitcoin/bitcoin.conf
    vim ~/Library/Application\ Support/Bitcoin/bitcoin.conf

Insert the following lines into the bitcoin.conf, and replce with your username and password.

    server=1
    daemon=1
    rpcuser=INVENT_A_UNIQUE_USERNAME
    rpcpassword=INVENT_A_UNIQUE_PASSWORD

    # If run on the test network instead of the real bitcoin network
    testnet=1

    # Notify when receiving coins
    walletnotify=/usr/local/sbin/rabbitmqadmin publish routing_key=peatio.deposit.coin payload='{"txid":"%s", "channel_key":"satoshi"}'

**Start Bitcoind**

    open /Applications/Bitcoin-Qt.app

### 7. Configure Peatio

**Clone the project**

    git clone git://github.com/peatio/peatio.git
    cd peatio
    bundle install

**Prepare configure files**

    bin/init_config

**Setup reCAPTCHA / Pusher**

* Peatio use [reCAPTCHA](https://www.google.com/recaptcha) to make sure certain operations is not done by bots. A development key/secrect pair is provided in `config/application.yml` (uncomment to use). PLEASE USE IT IN DEVELOPMENT/TEST ENVIRONMENT ONLY!
* Peatio depends on [Pusher](http://pusher.com). A development key/secret pair for development/test is provided in `config/application.yml` (uncomment to use). PLEASE USE IT IN DEVELOPMENT/TEST ENVIRONMENT ONLY!

More details to visit [pusher official website](http://pusher.com)

    # uncomment reCAPTCHA and Pusher related settings
    vim config/application.yml

**Setup bitcoind rpc endpoint**

    # replace username:password and port with the one you set in
    # username and password should only contain letters and numbers, do not use email as username
    # bitcoin.conf in previous step
    vim config/currencies.yml

**Config database settings**

    vim config/database.yml

    # Initialize the database and load the seed data
    bundle exec rake db:setup

**Run Daemons**

    # start all daemons
    bundle exec rake daemons:start

    # or start daemon one by one
    bundle exec rake daemon:matching:start
    ...

    # Daemon trade_executor can be run concurrently, e.g. below
    # line will start four trade executors, each with its own logfile.
    # Default to 1.
    TRADE_EXECUTOR=4 rake daemon:trade_executor:start

    # You can do the same when you start all daemons:
    TRADE_EXECUTOR=4 rake daemons:start

**Run Peatio**

    # start server
    bundle exec rails server

**Visit [http://localhost:3000](http://localhost:3000)**

    user: admin@peatio.dev
    pass: Pass@word8
