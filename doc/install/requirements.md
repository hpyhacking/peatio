Operating Systems
-----------------

Peatio is developed for Mac and Linux operating system, Ubuntu 12.04 LTS is recommended.

## Officially supports

* Ubuntu Linux 12.04 LTS
* Mac OS X Mavericks

## Ruby versions

Peatio requires Ruby (MRI) 2.1.0+. You will have to use the standard MRI implementation of Ruby.

## Hardware requirements

#### CPU

* 1 core works for under 100 users
* **2 cores is the recommended number of cores and supports up to 100 users**
* 4 cores supports up to 1,000 users
* 8 cores supports up to 10,000 users

#### Memory

* 1GB supports up to 100 users
* **2GB is the recommended memory size and supports up to 1,000 users**
* 4GB supports up to 10,000 users

#### Storage

If you run bitcoind at local, the necessary hard drive space largely depends on the size of the [blocks](https://en.bitcoin.it/wiki/Blocks) of Bitcoin network (15G for now). 40G is recommended at start.


#### Supported browsers

* Chrome (Latest stable version)
* Firefox (Latest released version)
* Safari 7+ (Know problem: required fields in html5 do not work)
* Opera (Latest released version)
* IE 10+

## Development Dependencies

* [RabbitMQ](https://www.rabbitmq.com/) is Peatio's backbone, it's the message broker doing all the message exchanges between daemons.
* Peatio use [Phantomjs](http://phantomjs.org/) to test JavaScript.

#### For Mac

**Install RabbitMQ**

    # You can find instructions here: https://www.rabbitmq.com/download.html
    brew install rabbitmq

**Install PhantomJS**

    # Install dependencies using Homebrew
    brew install phantomjs

** More details are in the [poltergeist](https://github.com/jonleighton/poltergeist/blob/master/README.md) doc.


#### For Ubuntu

**Install RabbitMQ**

You can find instructions here: https://www.rabbitmq.com/download.html

**Install PhantomJS**

    sudo apt-get install -y libfontconfig libfontconfig-dev libfreetype6-dev

* Download the [32 bit](https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-i686.tar.bz2)
or [64 bit](https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-x86_64.tar.bz2)
binary.
* Extract the tarball and copy `bin/phantomjs` into your `PATH`

** More details are in the [poltergeist](https://github.com/jonleighton/poltergeist/blob/master/README.md) doc.


## Support

Any Questions: [community@peatio.com](mailto:community@peatio.com)
