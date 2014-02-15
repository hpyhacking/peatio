Operating Systems
-----------------

Peatio is developed for Mac and Linux operating system.

## officially supports

* Ubuntu Linux 12.04 TLS
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

#### For Mac


**Install dependencies using Homebrew**

    brew install qt4 qrencode


#### For Ubuntu

**Install dependencies using apt**

    sudo apt-get install libqtwebkit-dev


## Support

Any Questions: [community@peatio.com](mailto:community@peatio.com)
