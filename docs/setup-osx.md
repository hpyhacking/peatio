# Setup local development environment on OS X

## Docker & peatio-workbench

#### We advise you to use [docker](https://www.docker.com) and [peatio-workbench](https://github.com/rubykube/peatio-workbench) as your local development environment

#### Follow [this](setup-with-docker.md) guide for container-based development environment setup

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
rbenv install 2.5.0
rbenv global 2.5.0

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
brew services start redis
```

## 5. Install RabbitMQ

Install rabbitmq brew package:

```shell
brew install rabbitmq
```

Start the rabbitmq server:

```shell
brew services start rabbitmq
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
walletnotify=/usr/local/sbin/rabbitmqadmin publish routing_key=peatio.deposit.coin payload='{"txid":"%s", "currency":"btc"}'
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
git clone git@github.com:rubykube/peatio.git
cd peatio
bundle install
```

#### Prepare configure files:

```shell
bin/init_config
```

#### Configure assets

Then install and run yarn:

    $ npm install -g yarn
    $ bundle exec rake tmp:create yarn:install

#### Setup bitcoind rpc endpoint

Edit `config/currencies.yml`.

Replace `username:password` and `port`.
`username` and `password` should only contain letters and numbers,
**do not use email as `username`**.

#### Setup database:

```shell
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake currencies:seed
bundle exec rake markets:seed
```

#### Run daemons

Read how to deal with Peatio daemons at [Peatio daemons](https://github.com/rubykube/peatio/blob/master/docs/peatio/daemons.md).

#### Setup the Google Authentication

- By default, it ask for Google Authentication. This parameter can be changed in `/config/application.yml` -> `OAUTH2_SIGN_IN_PROVIDER:    google`
- Setup a new Web application on https://console.developers.google.com
- Configure the Google Id, Secret and callback in `/config/application.yml`
- Note: Make sure your host ISN'T an IP in the callback config.  Looks like Google auth expect a callback to a DNS only

```
  GOOGLE_CLIENT_ID: <Google id>
  GOOGLE_CLIENT_SECRET: <Google secret>
  GOOGLE_OAUTH2_REDIRECT_URL: http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:3000/auth/google_oauth2/callback
```

#### Run Peatio

Finalize the config; open `/config/application.yml`
Set the DNS of your host (IP won't work if you use Google Authentication) 

```shell
URL_HOST: ec2-34-xxx-xxx-xx.compute-1.amazonaws.com:3000
```

Start the server:

```shell
bundle exec rails server -p 3000
```

Validate the server is working:

**visit [http://localhost:3000](http://localhost:3000)** or the public DNS of your server

Sign in with Google SSO

NOTE: At this point, the "trade" screen isn't working as you need to setup the trading server.  See next step.

### Step 10. Run Peatio Trading UI

Clone the repo and setup the Trading UI

```shell
cd ~/code
git clone https://github.com/rubykube/peatio-trading-ui.git
cd peatio-trading-ui
bundle install
```

Prepare configure files:

```shell
bin/init_config
```

Edit the `/config/application.yml` and set your app DNS.  Ex: 

```shell
PLATFORM_ROOT_URL: http://ec2-xx-xx-xxx-xxx.compute-1.amazonaws.com
```
Start the server

```shell
bundle exec rails server -p 4000
```

Refer to the release note here : https://github.com/rubykube/peatio/blob/master/docs/releases/1.5.0.md

### Step 11. Install nginx to setup a reverse proxy

```
brew install nginx
```
At this point you should see nginx running

But you need to edit the default config to setup the reverse proxy.
Open `/usr/local/etc/nginx/nginx.conf` in your favorite editor

Replace the content of the file by the following

```
#
# ATTENTION!
#
# Make sure to add the next line to /etc/hosts.
#
#   127.0.0.1 peatio.tech
#

server {
  server_name      peatio.tech;
  listen           80;
  proxy_set_header Host peatio.tech;

  location ~ ^/(?:trading|trading-ui-assets)\/ {
    proxy_pass http://127.0.0.1:4000;
  }

  location / {
    proxy_pass http://127.0.0.1:3000;
  }
}
```

Make sure to replace `http://peatio.tech` with your actual server DNS

Start nginx by running `sudo nginx`

