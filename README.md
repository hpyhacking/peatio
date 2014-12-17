An open-source crypto currency exchange
=====================================

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/peatio/peatio?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Peatio is a free and open-source crypto currency exchange implementation with the Rails framework and other cutting-edge technology.

[![Code Climate](https://codeclimate.com/github/peatio/peatio.png)](https://codeclimate.com/github/peatio/peatio)
[![Build Status](https://travis-ci.org/peatio/peatio.png?branch=master)](https://travis-ci.org/peatio/peatio)

### Mission

Our mission is to build the world best open-source crypto currency exchange with a high performance trading engine and safety which can be trusted and enjoyed by users. Additionally we want to move the crypto currency exchange technology forward by providing support and add new features. We are helping people to build easy their own exchange around the world.

Help is greatly appreciated, feel free to submit pull-requests or open issues.


### Features

* Designed as high performance crypto currency exchange.
* Built-in high performance matching-engine.
* Built-in [Proof of Solvency](https://iwilcox.me.uk/2014/proving-bitcoin-reserves) Audit.
* Built-in ticket system for customer support.
* Usability and scalibility.
* Websocket API and high frequency trading support.
* Support multiple digital currencies (eg. Bitcoin, Litecoin, Dogecoin etc.).
* Easy customization of payment processing for both fiat and digital currencies.
* SMS and Google Two-Factor authenticaton.
* [KYC Verification](http://en.wikipedia.org/wiki/Know_your_customer).
* Powerful admin dashboard and management tools.
* Highly configurable and extendable.
* Industry standard security out of box.
* Active community behind.
* Free and open-source.
* Created and maintained by [Peatio open-source group](http://peat.io).


### Known Exchanges using Peatio

* [Yunbi Exchange](https://yunbi.com) - A crypto-currency exchange funded by BitFundPE
* [One World Coin](https://oneworldcoin.com)
* [MarsX.io](https://acx.io) - Australian Cryptocurrency Exchange
* [Bitspark](https://bitspark.io) - Bitcoin Exchange in Hong Kong
* [Yes-BTC](http://www.yes-btc.com) - Bitcoin Exchange in Taiwan
* [Mulcoin.com](http://mulcoin.com)
* ecoinz.info (Launch soon) - New Zealand Cryptocurrency Exchange

### Mobile Apps ###

* [Boilr](https://github.com/andrefbsantos/boilr) - Cryptocurrency and bullion price alarms for Android

### Requirements

* Linux / Mac OSX
* Ruby 2.1.0
* Rails 4.0+
* Git 1.7.10+
* Redis 2.0+
* MySQL
* RabbitMQ

** More details are in the [doc](doc).


### Getting started

* [Setup on Mac OS X](doc/setup-osx.md)
* [Setup on Ubuntu](doc/setup-ubuntu.md)
* [Deploy production server](doc/deploy-ubuntu.md)

### API

You can interact with Peatio through API:

* [API v2](http://demo.peat.io/documents/api_v2?lang=en)
* [Websocket API](http://demo.peat.io/documents/websocket_api)
* [peatio-client-ruby](https://github.com/peatio/peatio-client-ruby) is the official ruby client of both HTTP/Websocket API.
* [peatio-client-python](https://github.com/JohnnyZhao/peatio-client-python) is a python client written by JohnnyZhao.
* [peatioJavaClient](https://github.com/classic1999/peatioJavaClient.git) is a java client written by classic1999.
* [yunbi-client-php](https://github.com/panlilu/yunbi-client-php) is a php client written by panlilu.

### Custom Style

Peatio front-end based Bootstrap 3.0 version and Sass, and you can custom exchange style for your mind.

* change bootstrap default variables in `vars/_bootstrap.css.scss`
* change peatio custom default variables in `vars/_basic.css.scss`
* add your custom variables in `vars/_custom.css.scss`
* add your custom css style in `layouts/_custom.css.scss`
* add or change features style in `features/_xyz.css.scss'

`vars/_custom.css.scss` can overwrite `vars/_basic.css.scss` defined variables
`layout/_custom.css.scss` can overwrite `layout/_basic.css.scss` and `layoputs/_header.css.scss` style

### Getting Involved

Want to report a bug, request a feature, contribute or translate Peatio?

* Browse our [issues](https://github.com/peatio/peatio/issues), comment on proposals, report bugs.
* Clone the peatio repo, make some changes according to our development guidelines and issue a pull-request with your changes.
* If you want to contact us, drop an email to [community@peatio.com](mailto:community@peatio.com)


### License

Peatio is released under the terms of the MIT license. See [http://peatio.mit-license.org](http://peatio.mit-license.org) for more information.


### DONATE

**Every satoshi of your kind donation goes into the ongoing work of making Peatio more awesome.**

**peatio-opensource-donate** address [1HjfnJpQmANtuW7yr1ggeDfyfe1kDK7rm3](https://blockchain.info/address/1HjfnJpQmANtuW7yr1ggeDfyfe1kDK7rm3)


### What is Peatio?

[Peatio](http://en.wikipedia.org/wiki/Pixiu) (Chinese: 貔貅) is a Chinese mythical hybrid creature considered to be a very powerful protector to practitioners of Feng Shui.

**[This illustration copyright for Peatio Team]**

![logo](public/peatio.png)


