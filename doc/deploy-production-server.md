### Introduction 
   welcome to the most advanced peatio release available all code has been refactored for JRuby compatability and executes faster than
   previous versions at every step FIX financial information exchange API has been added to bring the support of the entire financial
   eco system allowing for trading clients banks etc to connect with the exchange. also various UI and visual fixes have been added
   (more to come) and a market making system which will provide a trading partner for your users.
   please feel free to post issues and they will be handled rapidly.


Deploy production server on Ubuntu 16.04
-------------------------------------

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
11. Install Market making system

### 1. Setup deploy user

Create (if it doesn’t exist) deploy user, and assign it to the sudo group:

    sudo adduser deploy
    sudo usermod -a -G sudo deploy

Re-login as deploy user

### 2. Install Ruby

Make sure your system is up-to-date.

    sudo apt-get update
    sudo apt-get upgrade

Installing [rbenv](https://github.com/sstephenson/rbenv) using a Installer

    sudo apt-get install git-core curl zlib1g-dev build-essential \
                         libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 \
                         libxml2-dev libxslt1-dev libcurl4-openssl-dev \
                         python-software-properties libffi-dev

    cd
    git clone git://github.com/sstephenson/rbenv.git .rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL

    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL

Install JRuby through rbenv:

    sudo apt-get install default-jre  
    rbenv install jruby-9.1.13.0
    rbenv global jruby-9.1.13.0

Install bundler

    echo "gem: --no-ri --no-rdoc" > ~/.gemrc
    gem install bundler
    rbenv rehash

### 3. Install MySQL 5.6!

    sudo apt-get install software-properties-common 
    sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty universe'
    sudo apt-get update
    sudo apt-get install mysql-server-5.6 redis-server libmysqlclient-dev


### 4. Install Redis

sudo apt-get install redis-server

### 5. Install RabbitMQ

Please follow instructions here: https://www.rabbitmq.com/install-debian.html

    echo 'deb http://www.rabbitmq.com/debian/ testing main' |
    sudo tee /etc/apt/sources.list.d/rabbitmq.list
    wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc |
    sudo apt-key add -
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

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7

Add HTTPS support to APT

    sudo apt-get install apt-transport-https ca-certificates

Add the passenger repository. Note that this only works for Ubuntu 16.04. For other versions of Ubuntu, you have to add the appropriate 
repository according to Section 2.3.1 of this [link](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html).

    sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
    sudo apt-get update

Install nginx and passenger

    sudo apt-get install nginx-extras passenger

Next, we need to update the Nginx configuration to point Passenger to the version of Ruby that we're using. You'll want to open up /etc/nginx/nginx.conf in your favorite editor,

    sudo vim /etc/nginx/passenger.conf

find the following lines, and uncomment them:

    passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
    passenger_ruby /usr/bin/ruby;

update the second line to read:

    passenger_ruby /home/deploy/.rbenv/shims/ruby;

we will alsp need to enable passenger in nginx config file
  
    sudo vim /etc/nginx/nginx.conf 

and uncomment

    include  /etc/nginx/passenger.conf;.

### 8. Install JavaScript Runtime

A JavaScript Runtime is needed for Asset Pipeline to work. Any runtime will do but Node.js is recommended.

    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install nodejs


### 9. Install ImageMagick

    sudo apt-get -y install imagemagick gsfonts


### 10. Setup production environment variable

    echo "export RAILS_ENV=production" >> ~/.bashrc
    source ~/.bashrc

##### Clone the Source

    mkdir -p ~/peatio
    git clone git://github.com/muhammednagy/peatio.git ~/peatio/current
    cd peatio/current

    ＃ Install dependency gems
    bundle install --without development test --path vendor/bundle

##### Configure Peatio

**Prepare configure files**

    bin/init_config

**Setup Pusher**

* Peatio depends on [Pusher](http://pusher.com). A development key/secret pair for development/test is provided in `config/application.yml` (uncomment to use). PLEASE USE IT IN DEVELOPMENT/TEST ENVIRONMENT ONLY!

More details to visit [pusher official website](http://pusher.com)

    # uncomment Pusher related settings
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

**Precompile assets**

    bundle exec rake assets:precompile

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

When daemons don't work, check `log/#{daemon name}.rb.output` or `log/peatio:amqp:#{daemon name}.output` for more information (suffix is '.output', not '.log').

**SSL Certificate setting**

For security reason, you must setup SSL Certificate for production environment, if your SSL Certificated is been configured, please change the following line at `config/environments/production.rb`

    config.force_ssl = true

**Passenger:**

    sudo rm /etc/nginx/sites-enabled/default
    sudo ln -s /home/deploy/peatio/current/config/nginx.conf /etc/nginx/conf.d/peatio.conf
    sudo service nginx restart

**Liability Proof**

    # Add this rake task to your crontab so it runs regularly
    RAILS_ENV=production rake solvency:liability_proof

### 11. Installing Krypto-trading-bot

[***REFUGEES WELCOME!***](http://www.refugeesaid.eu/rab-campaign/)

[![Release](https://img.shields.io/github/release/ctubio/Krypto-trading-bot.svg)](https://github.com/ctubio/Krypto-trading-bot/releases)
[![Platform](https://img.shields.io/badge/platform-unix--like-lightgray.svg)](https://www.gnu.org/)
[![Software License](https://img.shields.io/badge/license-ISC-111111.svg)](https://raw.githubusercontent.com/ctubio/Krypto-trading-bot/master/LICENSE)
[![Software License](https://img.shields.io/badge/license-MIT-111111.svg)](https://raw.githubusercontent.com/ctubio/Krypto-trading-bot/master/COPYING)

[`K.sh`](https://github.com/ctubio/Krypto-trading-bot) is a very low latency [market making](https://github.com/ctubio/Krypto-trading-bot/blob/master/MANUAL.md#what-is-market-making) trading bot with a full featured [web interface](https://github.com/ctubio/Krypto-trading-bot#web-ui), it directly connects to [several cryptocoin exchanges](https://github.com/ctubio/Krypto-trading-bot/tree/master/etc#configuration-options). On a decent machine reacts to market data by placing and canceling orders in under milliseconds.

[![Build Status](https://img.shields.io/travis/ctubio/Krypto-trading-bot/master.svg?label=test%20build)](https://travis-ci.org/ctubio/Krypto-trading-bot)
[![Coverage Status](https://img.shields.io/coveralls/ctubio/Krypto-trading-bot/master.svg?label=code%20coverage)](https://coveralls.io/r/ctubio/Krypto-trading-bot?branch=master)
[![Quality Status](https://img.shields.io/codacy/grade/d48a59c313504f7988e3df031665f90f/master.svg)](https://www.codacy.com/app/ctubio/Krypto-trading-bot)
[![Dependency Status](https://img.shields.io/david/ctubio/Krypto-trading-bot.svg)](https://david-dm.org/ctubio/Krypto-trading-bot)
[![Open Issues](https://img.shields.io/github/issues/ctubio/Krypto-trading-bot.svg)](https://github.com/ctubio/Krypto-trading-bot/issues)
[![Open Issues](https://img.shields.io/github/issues/ctubio/tribeca.svg)](https://github.com/ctubio/tribeca/issues)

### <img src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f4be.png" align="middle" /> Latest version at https://github.com/ctubio/Krypto-trading-bot <img src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f51e.png" align="middle" /> <img src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f4b8.png" align="middle" />

[![Total Downloads](https://img.shields.io/npm/dt/hacktimer.svg)](https://github.com/ctubio/Krypto-trading-bot)
[![Week Downloads](https://img.shields.io/npm/dw/hacktimer.svg)](https://github.com/ctubio/Krypto-trading-bot)
[![Month Downloads](https://img.shields.io/npm/dm/hacktimer.svg)](https://github.com/ctubio/Krypto-trading-bot)
[![Day Downloads](https://img.shields.io/npm/dy/hacktimer.svg)](https://github.com/ctubio/Krypto-trading-bot)

Runs on unix-like systems. Persistence is achieved using a built-in server-less SQLite C++ interface. Installation via Docker is supported, but manual installation in a dedicated [Debian](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/) (or [Raspbian](https://www.raspberrypi.org/downloads/raspbian/)) or [CentOS](https://wiki.centos.org/Download) instance is recommended.

![Web UI Preview](https://raw.githubusercontent.com/ctubio/Krypto-trading-bot/master/etc/img/web_ui_preview.png)

The web UI is compatible with most web browsers/devices/resolutions, but Firefox or Chrome at 1600px are recommended. Doesn't require configuration of any web server (unless installed behind your own reverse proxy).

### Compatible Exchanges

||with Post-Only Orders support|without Post-Only|
|---|---|---|
|**without Maker fees**|[Coinbase GDAX](https://www.gdax.com/)<br> &#10239; _REST + WebSocket + FIX_|[HitBTC](https://hitbtc.com/)<br> &#10239; _REST + WebSocket_<br><br>|
|**with Maker and Taker fees**|[Bitfinex](https://www.bitfinex.com/)<br> &#10239; _REST + WebSocket_<br><br>[Poloniex](https://www.poloniex.com/)<br> &#10239; _REST_|[OKCoin.com](https://www.okcoin.com/)<br>[OKCoin.cn](https://www.okcoin.cn/)<br> &#10239; _REST + WebSocket_<br><br>[Korbit](https://www.korbit.co.kr/)<br> &#10239; _REST_|

All currency pairs are supported, otherwise please open a [new issue](https://github.com/ctubio/Krypto-trading-bot/issues/new?title=Missing%20currency%20pair) to easily include any missing currency that you would like.

## README
- Documentation
  - [README](#readme)
  - [MANUAL](https://github.com/ctubio/Krypto-trading-bot/blob/master/MANUAL.md)
- Installation
  - [Docker Installation](#docker-installation)
  - [Manual Installation](#manual-installation)
  - [Upgrade to the latest commit](#upgrade-to-the-latest-commit)
  - [Multiple instances party time](#multiple-instances-party-time)
- Information
  - [Compatible Exchanges](#compatible-exchanges)
  - [Configuration](#configuration)
  - [Application Usage](#application-usage)
  - [Web UI](#web-ui)
  - [Databases](#databases)
  - [Charts](#charts)
  - [Cloud Hosting](#cloud-hosting)
- Development
  - [XMR miner](#xmr-miner)
  - [Test units and Build notes](#test-units-and-build-notes)
  - [Unreleased Changelog](#unreleased-changelog)
  - [Release 3.0 Changelog](#release-30-changelog)
  - [Release 2.0 Changelog](#release-20-changelog)
  - [Release 1.0 Changelog](#release-10-changelog)
- Humans and Milk Mammals
  - [Unlock](#unlock)
  - [Donations](#donations)
  - [Help](#help)
  - [Issues](#issues)
  - [Votes](#votes)

### Docker Installation

See [etc/Dockerfile](https://github.com/ctubio/Krypto-trading-bot/tree/master/etc#dockerfile) section if you use winy (because the Manual Installation only works on unix-like platforms).

### Manual Installation
1. Ensure your target machine has installed `git`, `vim`, `make` and [node](https://nodejs.org/en/download/package-manager/).

2. Run in any location that you wish (feel free to customize the suggested folder name K):
```
 $ git clone ssh://git@github.com/ctubio/Krypto-trading-bot K
 $ cd K
 
 find and comment this line to prevent stunnel runing on port 4199 /src/server/cf.h#L238
 
 $ make install
 $ vim K.sh
```

See [configuration](#configuration) section while setting up the configuration options in your new config file `K.sh`.

Once the config file is ready, execute `./K.sh`.

Or `make start` to run `K.sh` in the background using [screen](https://www.decf.berkeley.edu/help/unix/screen.html); to see the output, attach the screen with `make screen`.

Feel free to run `make stop` or `make restart` anytime, and don't forget to [read the fucking manual](https://github.com/ctubio/Krypto-trading-bot/blob/master/MANUAL.md).

Troubleshooting:

 * Installation may fail if `g++` v6 was not selected on install. To fix it install manually `g++-6` (or with `make travis` on Ubuntu).

 * Create a temporary [swap file](https://stackoverflow.com/questions/17173972/how-do-you-add-swap-to-an-ec2-instance) (after install you can swapoff) if the installation fails with error: `virtual memory exhausted: Cannot allocate memory`.

 * If there is no wallet data on a given exchange, do a manual buy/sell order first using the website of the exchange.

 Optional:

 * See `./K.sh --help` and `make help`.

 * Replace the certificate at `etc/sslcert` folder with your own, see [web ui](https://github.com/ctubio/Krypto-trading-bot#web-ui) section. But, the certificate provided is a fully featured default openssl, that you may just need to authorise in your browser.

### Configuration

See [etc/K.sh.dist](https://github.com/ctubio/Krypto-trading-bot/blob/master/etc/K.sh.dist) file or your own `./K.sh` file.

It just contains a few variables with examples ready to be reused (the suggested urls will work), and at the very end of the file is the execution of the bot.

### Upgrade to the latest commit

Feel free anytime to check if there are new modifications with `make diff`.

Once you decide that is time to upgrade, execute `make latest` to download and install the latest modifications in your remote branch (or directly `make reinstall` to skip the validation of the new commit messages).

After upgrade to latest version, all running instances will be restarted.

`git` commands do not upgrade nothing because do not compile nothing (if you update the source with git, then later consider to run `make reinstall`).

### Multiple instances party time

Please note, an "instance" is in fact a `*.sh` config file located in the top level path; using a single machine and the same source folder, you can run as many instances as `*.sh` files you have in the top level path (limited by the available free RAM).

Anytime you can list the current instances running with `make list`.

Simple commands like `make start`, `make screen`, `make stop` or `make restart` (without any config file defined) will use the default config file `K.sh`.

To run multiple instances using a collection of config files:

1. Create a new config file with `cp etc/K.sh.dist X.sh && chmod +x X.sh` (use `X.sh` or any name but keep `.sh` extension).

2. Edit the new config file as you alternatively desire.

3. Run the new instance with `./X.sh` or `K=X.sh make start`, also the commands `make screen`, `make stop` and `make restart` allow the environment variable `K`, the value is simply the filename of the config file that you want to run; this value will also be used as the `uid` of the process executed by `screen`.

4. Open in the web browser the different pages of the ports of the different running instances, or display the UI of all instances together in a single page using the MATRYOSHKA link in the footer and the optional argument `--matryoshka=URL`.

After multiple config files are setup, to control them all together instead of one by one, the commands `make startall`, `make stopall` and `make restartall` are also available, just remember that config files with a filename starting with underscore symbol "_" will be skipped.

### Application Usage

1. Open your web browser to connect to HTTPS port `3000` (or your configured port number) of the machine running K. If you're running K locally on Mac/Windows on Docker, replace "localhost" with the address returned by `boot2docker ip`.

2. Read up on how to use K and market making in the [manual](https://github.com/ctubio/Krypto-trading-bot/blob/master/MANUAL.md).

3. Set up trading parameters to your liking in the web UI. Click the "BTC/USD" button so it is green to start making markets.

### Web UI

Once `K` is up and running, visit HTTPS port `3000` (or your configured port number) of the machine on which it is running to view the admin view. There are inputs for quoting parameters, grids to display market orders, market trades, your trades, your order history, your positions, and a big button with the currency pair you are trading. When you're ready, click that button green to begin sending out quotes. The UI uses a healthy mixture of socket.io and angularjs observed with reactivexjs.

If you want to generate your own certificate see [SSL for internal usage](http://www.akadia.com/services/ssh_test_certificate.html).

In case you really want to use plain HTTP, remove the files `server.crt` and `server.key` inside `etc/sslcert` folder.

### Databases

Each currency pair of each exchange will use a different sqlite database file.

All database files are located at `/data/db/K.*.db`, where `*` is the identifier with format `exchange.base_currency.quote_currency`; it is located outside the application path to survive reinstalls and wild `rm -rf path/to/K`.

You can copy any `.db` file to another machine when migrating or as a backup.

If a database file do not exists, the application will create it on boot; otherwise, it will load it and reuse it.

To see the data of each database file you can use https://github.com/sqlitebrowser/sqlitebrowser or similars.

To set a different database path or to set an [in-memory database](https://sqlite.org/inmemorydb.html), use `--database=PATH` argument (see `--help`).

### Charts

The metrics are not saved anywhere, is just UI data collected with a visibility retention of 6 hours, to display over time:

 * Market Fair Value with High and Low Prices
 * Trades Complete
 * Target Position for BTC currency (TBP)
 * Target Position for Fiat currency
 * STDEV and EWMA values for Quote Protection and APR
 * Amount available in wallet for buy
 * Amount held in open trades for buy
 * Amount available in wallet for sell
 * Amount held in open trades for sell
 * Total amount available and held at both sides in BTC currency
 * Total amount available and held at both sides in Fiat currency

### Cloud Hosting

If you ask me, [<img height="20px" src="https://user-images.githubusercontent.com/1634027/29756933-3e64c62e-8ba8-11e7-916a-3b0ae1481a52.png">](https://www.dreamhost.com/r.cgi?475987/cloud/) is a very nice web hosting company (awesome support team, awesome servers). Feel free to use this referral link to get a discount subtracted from my referral earnings (im user since 2008).

### XMR miner

Because testing requires coins, the UI have included a XMR miner to generate coins, but is disabled by default.

Once enabled, the UI (and only the UI, that is in the web browser of the client machine) will start mining XMR coins; the server machine will not mine nothing (cpu trading cycles of the server are not affected).

Is there because i use it, but you can run it too if you decide to collaborate with the development of both XMR and K.

### Test units and Build notes

Feel free to run `make test` anytime.

To rebuild the application with your modifications, see `make help` and choose a target.

To pipe the output to stdout, execute the application in the foreground with `./K.sh`.

To ignore the output, execute the application in the background with `screen -dmS K K.sh` or with the alias `make start`.

### Unreleased Changelog:

Added command-line arguments.

Updated quoting engine and gateways without nodejs.

Added Makefile to replace npm scripts.

Added PNG files as configuration files.

Added built-in C++ WWW Server to replace expressjs and socketio.

Added built-in SQLite C++ interface to replace external mongodb server.

Added Poloniex API.

### Release 3.0 Changelog:

Updated application name to K because of Kira.

Added nodejs7, typescript2, angular4 and reactivexjs.

Added cleanup of bandwidth, source code, dependencies and installation steps.

Added many quoting parameters thanks to Camille92 genius suggestions.

Added support for multiple instances/config files with nested matryoshka UI.

Added npm scripts, david-dm, travis-ci, coveralls and codacy.

Added historical charts to replace grafana.

Added C++ math functions.

Updated OKCoin API (since https://www.okcoin.com/t-354.html).

Updated Bitfinex API v2.

Added GDAX FIX API with stunnel.

Added Korbit API.

### Release 2.0 Changelog:

Added new quoting styles PingPong, Boomerang, AK-47.

Added cleanup of database records, memory usage and log recording.

Added audio notices, realtime wallet display, and grafana integration.

Added https, dark theme and new UI elements.

Added a bit of love to Kira.

### Release 1.0 Changelog:

see the upstream project [michaelgrosner/tribeca](https://github.com/michaelgrosner/tribeca).

### Unlock

The bot has all features unlocked, but to support further development by ctubio, the plan soOn is to lock some features.

To unlock all features currently nothing has to be done, but maybe, soOn, a payment of 0.12100000 BTC will be required.

 In case you are looking to extend the trial period, please generate a new API Key in your exchange (each API key have its own trial period). Otherwise if you choose to not support further development by ctubio, just keep running some old commit and do not upgrade.

The current payment is to support further development by ctubio to fix all bugs on the market you are paying against (an alternative [Votes](#votes) system).

To provide exclusivity to proefficient traders and to keep teenagers away, once the bot is bug-free, the payment required may be increased by a minimum of x3.

### Donations

nope, this project doesn't have maintenance costs. but you can donate to your favorite developer today! (or tomorrow!)

or see the upstream project [michaelgrosner/tribeca](https://github.com/michaelgrosner/tribeca).

or donate your time with programming or financial suggestions in the topical IRC channel [##tradingBot](https://kiwiirc.com/client/irc.domirc.net:6697/?theme=cli##tradingBot) at irc.domirc.net on port 6697 (SSL), or 6667 (plain) or feel free to make any question, but questions technically are not donations.

### Help

If you need installation or usage support contact me at [21.co/analpaper](https://21.co/analpaper/) (non-free high-priority service).

### Issues

To request new features open a [new issue](https://github.com/ctubio/Krypto-trading-bot/issues/new?title=Feature%20request) and explain your improvement as you consider.

To report errors open a [new issue](https://github.com/ctubio/Krypto-trading-bot/issues/new?title=Error%20report) only after collecting all the relevant log messages (run `./K.sh` to see the output).

