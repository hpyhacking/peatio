Developing document for Mac and Linux
-------------------------------------

The Peatio installation consists of setting up the following components:

1. Requirements
2. Bitcoind
3. Peatio


## 1. Requirements

* XCode and/or the XCode Command Line Tools.
* Homebrew
* Ruby 2.1.0, using [RVM](http://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv)
* MySQL
* Redis
* PhatomJS
* qrencode

** More details are in the [requirements doc](doc/install/requirements.md)

##### Install PhatomJS

**For Mac**

    brew install phantomjs

**For Linux**

* Download the [32 bit](https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-i686.tar.bz2)
or [64 bit](https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-x86_64.tar.bz2)
binary.
* Extract the tarball and copy `bin/phantomjs` into your `PATH`

** More details are in the [poltergeist](https://github.com/jonleighton/poltergeist/blob/master/README.md) doc.

##### Install qrencode

**For Mac**

    brew install qrencode

**For Linux**

    sudo apt-get install qrencode libqrencode-dev

## 2. Bitcoind

##### Install bitcoind

**For Mac**

    TODO

**For Linux**

    sudo add-apt-repository ppa:bitcoin/bitcoin
    sudo apt-get update
    sudo apt-get install -y bitcoind

##### Configure bitcoind

**For Mac**

    TODO

**For Linux**

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


## 3. Peatio

##### Clone the project

    git clone git@github.com:peatio/peatio.git
    cd peatio
    bundle install


##### Configuration

**Database:**

    vim config/database.yml

    # Initialize the database
    bundle exec rake db:setup

**E-mail:**

    TODO

#### Run Peatio

**Resque:**

    rake environment resque:work QUEUE=*
    rails server



