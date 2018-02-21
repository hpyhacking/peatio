# Setup local development environment on Ubuntu 14.04

## Docker & peatio-workbench

#### We advice you to use power of [docker](https://www.docker.com) and [peatio-workbench](https://github.com/rubykube/peatio-workbench) as local development environment

#### Follow [this](setup-with-docker.md) guide for container-based development environmetnt setup

### Overview

1. Install [Ruby](https://www.ruby-lang.org/en/)
2. Install [MySQL](http://www.mysql.com/)
3. Install [Redis](http://redis.io/)
4. Install [RabbitMQ](https://www.rabbitmq.com/)
5. Install [Bitcoind](https://en.bitcoin.it/wiki/Bitcoind)
6. Install [PhantomJS](http://phantomjs.org/)
7. Install JavaScript Runtime
8. Install ImageMagick
9. Configure Peatio

### Step 1: Install Ruby

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

### Step 2: Install MySQL

```shell
sudo apt-get install mysql-server mysql-client libmysqlclient-dev
```

### Step 3: Install Redis

Be sure to install the latest stable Redis, as the package,
the distro one can be outdated:

```shell
sudo apt-add-repository -y ppa:rwky/redis
sudo apt-get update
sudo apt-get install redis-server
```

### Step 4: Install RabbitMQ

Please follow instructions [here](https://www.rabbitmq.com/install-debian.html):

```shell
# add rabbitmq debian repo
sudo apt-add-repository 'deb http://www.rabbitmq.com/debian/ testing main'
curl http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | sudo apt-key add -

# install rabbitmq
sudo apt-get update
sudo apt-get install rabbitmq-server

# start the rabbitmq serveer
sudo rabbitmq-plugins enable rabbitmq_management
sudo service rabbitmq-server restart

# download and install rabbitmqadmin
wget http://localhost:15672/cli/rabbitmqadmin
chmod +x rabbitmqadmin
sudo mv rabbitmqadmin /usr/local/sbin
```

### Step 5: Install Bitcoind

```shell
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install bitcoind
```

#### Configure

Prepare config files:

```shell
mkdir -p ~/.bitcoin
touch ~/.bitcoin/bitcoin.conf
vim ~/.bitcoin/bitcoin.conf
```

Insert the following lines into `bitcoin.conf`,
and replce with your `username` and `password`.

```conf
server=1
daemon=1

# If run on the test network instead of the real bitcoin network
testnet=1

# You must set rpcuser and rpcpassword to secure the JSON-RPC api
# Please make rpcpassword to something secure, `5gKAgrJv8CQr2CGUhjVbBFLSj29HnE6YGXvfykHJzS3k` for example.
# Listen for JSON-RPC connections on <port> (default: 8332 or testnet: 18332)
rpcuser=USERNAME
rpcpassword=PASSWORD
rpcport=18332

# Notify when receiving coins
walletnotify=/usr/local/sbin/rabbitmqadmin publish routing_key=peatio.deposit.coin payload='{"txid":"%s", "channel_key":"satoshi"}'
```

Start bitcoin daemon:

```shell
bitcoind
```

### Step 6: Install PhantomJS

Peatio uses Capybara with PhantomJS to do the feature tests,
so if you want to run the tests. Install the PhantomJS is neccessary.

```shell
sudo apt-get update
sudo apt-get install build-essential chrpath git-core libssl-dev libfontconfig1-dev

cd /usr/local/share

PHANTOMJS_VERISON=1.9.8
sudo wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERISON-linux-x86_64.tar.bz2

sudo tar xjf phantomjs-$PHANTOMJS_VERISON-linux-x86_64.tar.bz2

sudo ln -s /usr/local/share/phantomjs-$PHANTOMJS_VERISON-linux-x86_64/bin/phantomjs /usr/local/share/phantomjs
sudo ln -s /usr/local/share/phantomjs-$PHANTOMJS_VERISON-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
sudo ln -s /usr/local/share/phantomjs-$PHANTOMJS_VERISON-linux-x86_64/bin/phantomjs /usr/bin/phantomjs
```

### Step 7: Install JavaScript Runtime

A JavaScript Runtime is needed for Asset Pipeline to work.
Any runtime will do but Node.js is recommended.

```shell
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt-get install nodejs
```

### Step 8: Install ImageMagick

```shell
sudo apt-get install imagemagick
```

### Step 9: Configure Peatio

Clone the project:

```shell
git clone git://github.com/peatio/peatio.git
cd peatio
bundle install
```

Prepare configuration files:

```shell
bin/init_config
```

#### Setup Pusher

Peatio depends on [pusher](http://pusher.com).
A development key/secret pair for development/test
is provided in `config/application.yml`.
PLEASE USE IT IN DEVELOPMENT/TEST ENVIRONMENT ONLY!

Set (or simply uncomment) pusher-related settings in `config/application.yml`.

You can always find more details about pusher configuration at [pusher website](http://pusher.com)

#### Setup bitcoind rpc endpoint

Edit `config/currencies.yml`.

Replace `username:password` and `port`.
`username` and `password` should only contain letters and numbers,
**do not use email as `username`**.

#### Setup database:

```shell
bundle exec rake db:setup
```

#### Run daemons

Read how to deal with Peatio daemons at [Peatio daemons](https://github.com/rubykube/peatio/blob/master/docs/peatio/daemons.md).

#### Genetare liability proof

To generate liability proof run:

```shell
bundle exec rake solvency:liability_proof
```
Otherwise you will get an exception at the "Solvency" page.

#### Run Peatio

Start the server:

```shell
bundle exec rails server
```

Once server is up and running, **visit [http://localhost:3000](http://localhost:3000)**

Sign in:

* user: admin@peatio.dev
* pass: Pass@word8
