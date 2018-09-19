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
10. Configure peatio-trading-ui
11. Setup the nginx reverse-proxy

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

\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.5.0 --gems=rails
```

If you want to skip fetching documentation when installing gems,
do the following:

```shell
echo "gem: --no-ri --no-rdoc" > ~/.gemrc
```

## Running backend services

You can install manually all services like mysql, redis and rabbitmq
or you docker compose file

```shell
docker-compose -f config/backend.yml up -d
```

### Step 2: Install MySQL

```shell
sudo apt-get install mysql-server mysql-client libmysqlclient-dev
```

Login to mysql and set the password for the root user

Add the environement variable (ideally in .bashrc, and don't forget to `$ source ~/.bashrc` after editing the file)

    export DATABASE_HOST=<host of your sql>
    export DATABASE_USER=<username for root usually>
    export DATABASE_PASS=<pwd for root>

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
walletnotify=/usr/local/sbin/rabbitmqadmin publish routing_key=peatio.deposit.coin payload='{"txid":"%s", "currency":"btc"}'
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
mkdir code
cd code
git clone https://github.com/rubykube/peatio.git
cd peatio
bundle install
```

Prepare configuration files:

```shell
bin/init_config
```

Then install and run yarn:

    $ npm install -g yarn
    $ bundle exec rake tmp:create yarn:install


#### Setup bitcoind rpc endpoint

Edit `config/seed/currencies.yml`.

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

Make sure you are in /peatio directory

Run `$ god -c lib/daemons/daemons.god` to start the deamon

More info about Peatio daemons at [Peatio daemons](https://github.com/rubykube/peatio/blob/master/docs/peatio/daemons.md).

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
$ bundle exec rails server -p 3000
```

If you setup peatio-workbench on a server (like AWS ec2)
- Make sure the port 3000 is open your server
- Start the server by passing the ip in parameter

```shell
$ bundle exec rails server -b 0.0.0.0
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
sudo apt-get update
sudo apt-get install nginx
sudo ufw allow 'Nginx HTTP'
systemctl status nginx

```
At this point you should see nginx running

But you need to edit the default config to setup the reverse proxy.
Open `/etc/nginx/sites-available/default` in your favorite editor

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

Verify that the syntax of the config file is valid : `$ sudo nginx -t`

Restart nginx by running `sudo systemctl restart nginx`
