# Setup local development environment on OS X

## Overview

1. Install [Homebrew](http://brew.sh/)
2. Install [Ruby](https://www.ruby-lang.org/en/)
3. Install [MySQL](http://www.mysql.com/)
4. Install [Redis](http://redis.io/)
5. Install [RabbitMQ](https://www.rabbitmq.com/)
6. Install [Bitcoind](https://en.bitcoin.it/wiki/Bitcoind)
7. Install [PhantomJS](http://phantomjs.org/)
8. Install ImageMagick
9. Configure Peatio

## 1. Install Homebrew

```shell
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
```

## 2. Install Ruby

Install rbenv:

```shell
brew install rbenv ruby-build
```

Add rbenv to bash so that it loads every time you open a terminal:

```shell
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
source ~/.bash_profile
```

Install Ruby and set it as the default version:

```shell
rbenv install 2.2.2
rbenv global 2.2.2

ruby -v
```

Install bundler:

```shell
echo "gem: --no-ri --no-rdoc" > ~/.gemrc
gem install bundler
rbenv rehash
```

## 3. Install MySQL

Install mysql brew package:

```shell
brew install mysql
```

Start the mysql server:

```shell
mysql.server start
```

## 4. Install Redis

Install redis brew package:

```shell
brew install redis
```

Start the redis server:

```shell
redis-server /usr/local/etc/redis.conf
```

## 5. Install RabbitMQ

Install rabbitmq brew package:

```shell
brew install rabbitmq
```

Start the rabbitmq server:

```shell
rabbitmq-server
```

## 6. Install Bitcoind

Download and Install [Bitcoin Core](http://bitcoin.org/en/download).
Prepare config files:

```shell
mkdir -p ~/Library/Application\ Support/Bitcoin
touch ~/Library/Application\ Support/Bitcoin/bitcoin.conf
vim ~/Library/Application\ Support/Bitcoin/bitcoin.conf
```

Insert the following lines into `bitcoin.conf`. Don't forget to replace your username and password.

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

Open the bitcoin app:

```shell
open /Applications/Bitcoin-Qt.app
```

## 7. Install PhantomJS

Peatio uses Capybara with PhantomJS to do the feature tests,
so if you want to run the tests. Install the PhantomJS is neccessary.

```shell
brew install phantomjs
```

## 8. Install ImageMagick

```shell
brew install imagemagick
```

## 9. Configure Peatio

#### Clone the project:

```shell
git clone git@github.com/rubykube/peatio.git
cd peatio
bundle install
```

#### Prepare configure files:

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

#### Run Daemons

Start all daemons:

```shell
bundle exec rake daemons:start
```

Or start daemons one by one:

```shell
$ bundle exec rake daemon:matching:start
...

# Daemon trade_executor can be run concurrently, e.g. below
# line will start four trade executors, each with its own logfile.
# Default to 1.
$ TRADE_EXECUTOR=4 rake daemon:trade_executor:start
...

# You can do the same when you start all daemons:
$ TRADE_EXECUTOR=4 rake daemons:start
...
```

If daemons don't work, check `log/#{daemon name}.rb.output`
or `log/peatio:amqp:#{daemon name}.output`
for more information (suffix is '.output', not '.log').

#### Run Peatio

Start the server:

```shell
bundle exec rails server
```

Once server is up and running, **visit [http://localhost:3000](http://localhost:3000)**

Sign in:

* user: admin@peatio.dev
* pass: Pass@word8
