![Cryptocurrency Exchange Platform - Baseapp](https://github.com/openware/meta/raw/main/images/github_peatio.png)

<h3 align="center">
<a href="https://www.openware.com/sdk/docs.html#peatio">Guide</a> <span>&vert;</span> 
<a href="https://www.openware.com/sdk/api/peatio/peatio-user-api-v2.html">API Docs</a> <span>&vert;</span> 
<a href="https://www.openware.com/">Consulting</a> <span>&vert;</span> 
<a href="https://t.me/peatio">Community</a>
</h3>
<h6 align="center">Component part of <a href="https://github.com/openware/opendax">OpenDAX Trading Platform</a></h6>

---

# Peatio - Cryptocurrency Exchange Software

[![Build Status](https://ci.openware.work/api/badges/openware/peatio/status.svg)](https://ci.openware.work/openware/peatio)
[![Telegram Chat](https://cdn.rawgit.com/Patrolavia/telegram-badge/8fe3382b/chat.svg)](https://t.me/peatio)

## What is Peatio

Peatio is a free and open-source crypto-currency exchange implementation with the Rails framework.
This is a fork of Peatio designed for micro-services architecture. We have simplified the code
in order to use only Peatio API with external frontend and server components.

Peatio is the core accounting component and configuration for markets; it is part of OpenDAX system.

## Getting Started

OpenDAX is a container distribution, the fastest way to install the full stack is using [OpenDAX](https://github.com/openware/opendax)
OpenDAX can be installed under 15 minutes on any Linux / Mac OS X environment with Docker.

```
# To install
git clone https://github.com/openware/opendax.git
# Follow the README instructions
# Configure config/app.yml
bundle install
bundle exec rake service:all
# Open your browser on www.app.local (please it in /etc/hosts)
```

To build your own exchange you should now run Peatio as a backend instead of forking the repository,
and extend it using other microservices such as [Barong](https://www.github.com/rubykube/barong).

## System Overview

![Cryptocurrency Exchange Platform overview](https://github.com/openware/meta/raw/main/images/system.png)

This is a service oriented architecture; the system is designed to be customized by creating Applogic which is your api code.
Barong will dispatch the traffic on your api to extend the current system.

## Mission

Our mission is to build an open-source [crypto exchange software](https://www.openware.com) with a high performance trading engine and incomparable security. We are moving toward dev/ops best practices of running an enterprise grade exchange.

We provide webinar or on site training for installing, configuring and administration best practices of Peatio.
Feel free to contact us for joining the next training session: [Openware.com](https://www.openware.com)

Help is greatly appreciated, feel free to submit pull-requests or open issues.

## Things You Should Know

**RUNNING A CRYPTO CURRENCY EXCHANGE IS HARD.**

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
* Built-in multiple wallet support (e.g. deposit, hot, warm and cold)
* Built-in [plugable coin API](https://www.openware.com/sdk/2.6/docs/peatio/coins/development.html)
* Build-in Management API - server-to-server API with high privileges
* Build-in RabbitMQ Event API
* Usability and scalability
* Websocket API and high frequency trading support
* Support multiple digital currencies (e.g. Bitcoin, Litecoin, Ethereum, Ripple etc.)
* Support ERC20 Tokens
* API endpoint for FIAT deposits or payment gateways.
* Powerful admin dashboard and management tools
* Highly configurable and extendable
* Industry standard security out of box
* Maintained by [Openware.com](https://www.openware.com)
* [KYC Verification](http://en.wikipedia.org/wiki/Know_your_customer) provided by [Barong](https://www.github.com/openware/barong)

## Contribute

Please see [CONTRIBUTING.md](https://www.openware.com/sdk/2.6/docs/peatio/contributing.html) for details on how to contribute
issues, fixes, and patches to this project.

## Getting Started

We advice to use [minimalistic environment](#minimalistic-local-development-environment-with-docker-compose) if you want to develop only Peatio and don't touch processes which interact with other components.

Otherwise we advice to use [microkube based environment](#local-development-environment-with-microkube)

### Minimalistic local development environment with docker-compose:

#### Prerequisites
* [Docker](https://docs.docker.com/install/) installed
* [Docker compose](https://docs.docker.com/compose/install/) installed
* Ruby 2.6.5
* Rails 5.2.3+

## Installation

### Local development install

1. Set up initial configuration `./bin/setup`
2. Start peatio daemons `god -c lib/daemons/daemons.god`
3. Add this to your `/etc/hosts`:
```
127.0.0.1 www.app.local
127.0.0.1 peatio.app.local
127.0.0.1 barong.app.local
```
4. Start rails server `JWT_PUBLIC_KEY=$(cat config/secrets/rsa-key.pub| base64 -w0) rails s -b 0.0.0.0` 
(`base64 -b0` for macOS)


### Local development environment with docker compose:

We suggest you to start using Peatio by installing [OpenDAX](https://github.com/openware/opendax).
[OpenDAX](https://github.com/openware/opendax) which is based on
[Docker containers](https://www.docker.com/what-docker) is a convenient and straightforward way to start
Peatio crypto exchange software development environment.

#### Prerequisites
* [Docker](https://docs.docker.com/install/) installed
* [Docker compose](https://docs.docker.com/compose/install/) installed

#### Start OpenDAX ready to use

Follow [OpenDAX](https://github.com/openware/opendax) documentation for the latest Peatio installation information.

#### [Barong](https://github.com/openware/barong)

Barong is an essential part of Openware [crypto exchange software](https://www.openware.com) stack. It's providing the authentication service, it provides KyC and 2FA features out of the box.

Barong manages roles and kyc level across all applications from the OpenDAX stack. It can be easily extended using Rest Management API and Event API.

##### Barong key features

* KYC Verification for individuals
* SMS and Google two-factor authentication
* Transaction Signature support
* Implement JWT standard to authenticate users of every microservice of the OpenDAX stack

Start barong:

```sh
$> docker-compose run --rm barong bash -c "./bin/link_config && ./bin/setup"
$> docker-compose up -d barong
```

This will output password for **admin@barong.io**. Default password is **`Qwerty123`**

#### Peatio

Start peatio server

```sh
$> docker-compose run --rm peatio bash -c "bundle exec rake db:create db:migrate db:seed"
$> docker-compose up -d peatio
```

After all of that you can start using Peatio in your browser just by following one of the hosts which you added earlier.

## API

You can interact with Peatio through API:

* Account, Market & Public API v2
* Management API v2
* Websocket API
* Event API (AMQP)

## Getting Involved
We want to make it super-easy for Peatio users and contributors to talk to us and connect with each other, to share ideas, solve problems and help make Peatio awesome. Here are the main channels we're running currently, we'd love to hear from you on one of them:

### Discourse

[Rubykube Discourse Forum](https://discuss.rubykube.io)

This is for all Peatio users. You can find guides, recipes, questions, and answers from Snowplow users including the Peatio.tech team.
We welcome questions and contributions!

### Telegram

[@peatio](https://t.me/peatio)

Chat with us and other community members on Telegram.

### GitHub
Peatio issues

If you spot a bug, then please raise an issue in our main GitHub project (Openware Peatio)[https://github.com/openware/peatio/]; likewise, if you have developed a new feature or an improvement in your Rubykube Peatio fork, then send us a pull request!
If you want to brainstorm a potential new feature, then the Telegram group is the best place to start (see above).

### Email
hello@openware.com

If you want to talk directly to us (e.g. about a commercially sensitive issue), email is the easiest way.

## Getting Support and Customization

If you need help with running/deploying/customizing Peatio,
you can contact us on [Openware.com](https://www.openware.com).

Contact us by email: [hello@openware.com](mailto:hello@openware.com)

## License

Peatio is released under the terms of the [MIT license](http://peatio.mit-license.org).

## What is Peatio?

[Peatio](http://en.wikipedia.org/wiki/Pixiu) (Chinese: 貔貅) is a Chinese mythical hybrid creature
considered to be a very powerful protector to practitioners of Feng Shui.

