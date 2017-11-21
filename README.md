# Peatio - an open-source crypto currency exchange

[![Build Status](https://ci.helioscloud.com/api/v1/teams/heliostech/pipelines/peatio/jobs/test-master/badge)](https://ci.helioscloud.com/teams/heliostech/pipelines/peatio/jobs/test-master)

### [peatio.tech](https://www.peatio.tech) fork

Peatio is a free and open-source crypto currency exchange implementation with the Rails framework and other cutting-edge technology.

## Mission

Our mission is to build the world best open-source crypto currency exchange with a high performance trading engine and safety which can be trusted and enjoyed by users. Additionally we want to move the crypto currency exchange technology forward by providing support and add new features. We are helping people to build easy their own exchange around the world.

Help is greatly appreciated, feel free to submit pull-requests or open issues.

## Things You Should Know

**RUNNING A EXCHANGE IS HARD.**

Peatio makes it easier, but running an exchange is still harder than a blog, which you can download the source code and following the guide or even a cool installer and boom!!! a fancy site is there to profit. We always prioritize security and speed higher than 1-click setup. We split Peatio to many components (processes) so it's flexible to deploy and scalable.

**SECURITY KNOWLEDGE IS A REQUIREMENT.**

Peatio cannot protect your customers when you leave your admin password 1234567, or open sensitive ports to public internet. No one can. Running an exchange is a very risky task because you're dealing with money directly. If you don't known how to make your exchange secure, hire an expert.

You must know what you're doing, there's no shortcut. Please get prepared before continue:

* Rails knowledge
* Security knowledge
* System administration

## Features

* Designed as high performance crypto currency exchange
* Built-in high performance matching-engine
* Built-in [Proof of Solvency](https://iwilcox.me.uk/2014/proving-bitcoin-reserves) Audit
* Built-in ticket system for customer support
* Usability and scalibility
* Websocket API and high frequency trading support
* Support multiple digital currencies (eg. Bitcoin, Litecoin, Dogecoin etc.)
* Easy customization of payment processing for both fiat and digital currencies
* [KYC Verification](http://en.wikipedia.org/wiki/Know_your_customer)
* Powerful admin dashboard and management tools
* Highly configurable and extendable
* Industry standard security out of box
* Active community behind
* Free and open-source
* Maintained by [peatio.tech](https://www.peatio.tech)

## Known Exchanges using Peatio

* **[peatio.tech](https://www.peatio.tech)** - provides Peatio support (add custom features, deploy to the cloud, etc)
* [Yunbi Exchange](https://yunbi.com) - a crypto-currency exchange funded by BitFundPE
* [Bitspark](https://bitspark.io) - bitcoin exchange in Hong Kong
* [MarsX.io](https://acx.io) - australian cryptocurrency rxchange
* [One World Coin](https://oneworldcoin.com)

## Mobile Apps

* [Boilr](https://github.com/andrefbsantos/boilr) - cryptocurrency and bullion price alarms for Android

## Requirements

* Linux / Mac OSX
* Ruby 2.2.8
* Rails 4.0+
* Git 1.7.10+
* Redis 2.0+
* MySQL
* RabbitMQ

Find more details in the [docs directory](docs).

## Getting Started

Local development setup:

* [on Mac OS X](docs/dev/setup/osx.md)
* [on Ubuntu](docs/dev/setup/ubuntu.md)

Production setup:

* [Deploy production server on Ubuntu](docs/ops/deploy/ubuntu.md)
* [Using Peatio docker image](docs/ops/deploy/docker.md)

## API

You can interact with Peatio through API:

* [API v2 docs](https://demo.peatio.tech/documents/api_v2?lang=en)
* [Websocket API docs](https://demo.peatio.tech/documents/websocket_api)

Here're some API clients/wrappers:

* [peatio-client-ruby](https://github.com/peatio/peatio-client-ruby) is the official ruby client of both HTTP/Websocket API.
* [peatio-client-python by JohnnyZhao](https://github.com/JohnnyZhao/peatio-client-python) is a python client written by JohnnyZhao.
* [peatio-client-python by czheo](https://github.com/JohnnyZhao/peatio-client-python) is a python wrapper similar to peatio-client-ruby written by czheo.
* [peatioJavaClient](https://github.com/classic1999/peatioJavaClient.git) is a java client written by classic1999.
* [yunbi-client-php](https://github.com/panlilu/yunbi-client-php) is a php client written by panlilu.

## Custom Styles

Peatio front-end based Bootstrap 3.0 version and Sass, and you can custom exchange style for your mind.

* change bootstrap default variables in `vars/_bootstrap.css.scss`
* change peatio custom default variables in `vars/_basic.css.scss`
* add your custom variables in `vars/_custom.css.scss`
* add your custom css style in `layouts/_custom.css.scss`
* add or change features style in `features/_xyz.css.scss`

`vars/_custom.css.scss` can overwrite `vars/_basic.css.scss` defined variables
`layout/_custom.css.scss` can overwrite `layout/_basic.css.scss` and `layoputs/_header.css.scss` style

## Getting Involved

Want to report a bug, request a feature, contribute or translate Peatio?

* Browse our [issues](https://github.com/rubykube/peatio/issues),
  comment on proposals, report bugs.
* Clone the peatio repo, make some changes according to our development
  guidelines and issue a pull-request with your changes.
* If you need technical support or customization service,
  contact us: [hello@peatio.tech](mailto:hello@peatio.tech)

## Getting Support and Customization

If you need help with running/deploying/customizing Peatio,
you can contact us on [peatio.tech](https://www.peatio.tech).

## License

Peatio is released under the terms of the [MIT license](http://peatio.mit-license.org).

## What is Peatio?

[Peatio](http://en.wikipedia.org/wiki/Pixiu) (Chinese: 貔貅) is a Chinese mythical hybrid creature
considered to be a very powerful protector to practitioners of Feng Shui.

**[This illustration copyright for Peatio Team]**

![logo](public/peatio.png)
