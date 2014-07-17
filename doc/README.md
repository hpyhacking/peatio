Operating Systems
-----------------

Peatio is developed for Mac and Linux operating system, Ubuntu 14.04 LTS is recommended.

## Officially supports

* Ubuntu Linux 14.04 LTS
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
* PhantomJS

## Support

Any Questions: [community@peatio.com](mailto:community@peatio.com)
