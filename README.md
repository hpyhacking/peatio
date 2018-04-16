# Peatio - an open-source crypto currency exchange

[![Build Status](https://travis-ci.org/rubykube/peatio.svg?branch=master)](https://travis-ci.org/rubykube/peatio)
[![Telegram Chat](https://cdn.rawgit.com/Patrolavia/telegram-badge/8fe3382b/chat.svg)](https://t.me/peatio)

## [Peatio.tech](https://www.peatio.tech) Introduction

Peatio is a free and open-source crypto currency exchange implementation with the Rails framework.
Peatio.tech is a fork of Peatio designed for micro-services architecture. We have simplified the code
in order to use only Peatio API with external frontend and server components.

To build your own exchange you should now run Peatio as a backend instead of forking the repository,
and extend it using other microservices such as [Barong](https://www.github.com/rubykube/barong).

## Mission

Our mission is to build an open-source crypto currency exchange with a high performance trading engine and incomparable security. We are moving toward dev/ops best practices of running an enterprise grade exchange.

We provide webinar or on site training for installing, configuring and administration best practices of Peatio.
Feel free to contact us for joining the next training session: [Peatio.tech](https://www.peatio.tech)

Help is greatly appreciated, feel free to submit pull-requests or open issues.

## Requirements

* Linux / Mac OSX
* Docker / Kubernetes
* Ruby 2.5.0
* Rails 4.2+
* Redis 2.0+
* MySQL 5.7
* RabbitMQ

Find more details in the [docs directory](docs).

## Getting Started

Local development setup:

* [Docker compose](https://github.com/rubykube/peatio-workbench)
* [on Mac OS X](docs/setup-osx.md)
* [on Ubuntu](docs/setup-ubuntu.md)

Production setup:

* [Deploy production cluster with kite](https://github.com/rubykube/kite/blob/master/README.md)
* [Kubernetes deployment architecture](docs/architecture.md)

## Things You Should Know

**RUNNING AN EXCHANGE IS HARD.**

This repository is not a turn key solution and will require engineering and design of security process by your company, with or without our assistance. This repository is one component among many we recommend using for composing an enterprise grade exchange. It is highly recommended to deploy a UAT environment and build automated tests for your needs, including Functional tests, Smoke tests and Security vulnerability scans. You may not need to have an active developer on Peatio source code, however, we recommend the following team setup: 1 dev/ops, 3 frontend developers (react / angular), 2 QA engineers, 1 Security Officer.

**SECURITY KNOWLEDGE IS A REQUIREMENT.**

Peatio cannot protect your customers if you leave your admin password 1234567, or open sensitive ports to public internet. No one can. Running an exchange is a very risky task because you're dealing with money directly. If you don't know how to make your exchange secure, hire an expert.

You must know what you're doing, there's no shortcut. Please get prepared before you continue:

* Rails knowledge
* Security knowledge
* Cloud and Linux administration
* Docker and Kubernetes administration
* Micro-services and OAuth 2.0

## Features

* Designed as high performance crypto currency exchange
* Built-in high performance matching-engine
* Built-in [Proof of Solvency](https://iwilcox.me.uk/2014/proving-bitcoin-reserves) Audit
* Usability and scalability
* Websocket API and high frequency trading support
* Support multiple digital currencies (eg. Bitcoin, Litecoin, Dogecoin etc.)
* API end point for FIAT deposits or payment gateways.
* Powerful admin dashboard and management tools
* Highly configurable and extendable
* Industry standard security out of box
* Maintained by [peatio.tech](https://www.peatio.tech)
* [KYC Verification](http://en.wikipedia.org/wiki/Know_your_customer) provided by [Barong](https://www.github.com/rubykube/peatio)

## API

You can interact with Peatio through API:

* [API v2 docs](https://demo.peatio.tech/documents/api_v2?lang=en)
* [Websocket API docs](https://demo.peatio.tech/documents/websocket_api)

Here are some API clients/wrappers:

* [peatio-client-ruby](https://github.com/peatio/peatio-client-ruby) is the official ruby client of both HTTP/Websocket API.
* [peatio-client-python by JohnnyZhao](https://github.com/JohnnyZhao/peatio-client-python) is a python client written by JohnnyZhao.
* [peatio-client-python by czheo](https://github.com/JohnnyZhao/peatio-client-python) is a python wrapper similar to peatio-client-ruby written by czheo.
* [peatioJavaClient](https://github.com/classic1999/peatioJavaClient.git) is a java client written by classic1999.
* [yunbi-client-php](https://github.com/panlilu/yunbi-client-php) is a php client written by panlilu.

## Custom Styles

Peatio front-end is based Bootstrap 3.0 and Sass, so you can customize the style of your exchange.

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

Contact us by email: [hello@peatio.tech](mailto:hello@peatio.tech)

## License

Peatio is released under the terms of the [MIT license](http://peatio.mit-license.org).

## What is Peatio?

[Peatio](http://en.wikipedia.org/wiki/Pixiu) (Chinese: 貔貅) is a Chinese mythical hybrid creature
considered to be a very powerful protector to practitioners of Feng Shui.

**[This illustration copyright for Peatio Team]**

![logo](public/peatio.png)
