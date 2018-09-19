# Rubykube Crypto Platform Architecture (RKCP)

## System Overview

Rubykube Crypto-Platform, is a distribution of component working together to form
a crypto-currency cluster on Kubernetes.

## System Requirements

 * Amazon AWS, Google Cloud GCP, Azure account
 * Kubernetes cluster deployed using Kite
 * MySQL 5.7 Highly available (RDS / Cloud SQL)
 * Blockchain services or nodes running in VM
 * RabbitMQ service running in the cluster or in VM

## Component Description

### Kite

Kite is a dev/ops framework for bootstraping any cloud provider and deploy a stack
using infrastructure as code best practices.

Kite 2.0 is a modular structure leveraging git and terraform with multi-environment management.

[Kite project](https://github.com/rubykube/kite)

#### Terraform

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

Kite uses terraform modules for initial configuration of the cloud account. We recommend using terraform for IAM config, VPC creation, networks and firewall.

[Terraform project](https://www.terraform.io/)

#### Bosh and Concourse

BOSH is a project that unifies release engineering, deployment, and lifecycle management of small and large-scale cloud software. BOSH can provision and deploy software over hundreds of VMs. It also performs monitoring, failure recovery, and software updates with zero-to-minimal downtime.

Kite and RKCP use Bosh for deploying blockchain nodes as a service.
Components managed by bosh are:
 * Vault
 * Bitcoin / Dash blockchain nodes
 * Concourse CI
 * RabbitMQ
 * Prometheus with Grafana for monitoring

[Bosh project](http://bosh.io/)

#### Vault

Vault is a tool for securely accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, or certificates. Vault provides a unified interface to any secret, while providing tight access control and recording a detailed audit log.

RKCP rely mainly on vault for keeping secrets, wallets secrets, certificates and OTP seeds.

[Vault project](https://www.vaultproject.io/)

#### Kubernetes

Kubernetes is a portable, extensible open-source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation. It has a large, rapidly growing ecosystem. Kubernetes services, support, and tools are widely available.

Google open-sourced the Kubernetes project in 2014. Kubernetes is built upon a decade and a half of experience that Google has with running production workloads at scale, combined with best-of-breed ideas and practices from the community.

Kubernetes is the foundation of the RK Crypto-Platform (RKCP), we levarage all the features for auto-healing, scaling design and fail over.
We only recommend Kubernetes for production environments.

[Kubernetes project](https://www.kubernetes.io)

### Peatio

Peatio act as the main Accounting gateway between Fiat and Crypto-Currencies, Peatio is in charge of maintaining the Member balance for engaging trading activities.

We only use peatio as an API, we only configure it per deployments but continue using the vanilla open-source Peatio.
We build a docker container from sources available on docker hub rubykube/peatio.

We ship weekly improvements on Peatio container, by using a fork you won't be able to upgrade your deployments with newest features.

Our goal and roadmap is to provide advanced API endpoints in order to be able to customize all behaviors around Peatio such as:
 * Plug in payment gateways
 * Plug in liquidity providers
 * Replace Trade matching worker
 * Consume Peatio events using Event API

[Peatio project](https://github.com/rubykube/peatio)

#### Peatio Workbench

Peatio workbench is the recommended development, test and integration environment for new developers.

[Peatio Workbench](https://github.com/rubykube/peatio-workbench)

#### Peatio SDK

Peatio SDK is a javascript SDK we maintain for running QA Test scenarios.
Use Peatio SDK to interact with the server side backends such as Peatio and Barong.

[Peatio SDK](https://github.com/rubykube/peatio-workbench)

#### Coinhub

Blockchain gateway from Kubernetes to external Blockchain APIs.

[Coinhub project](https://github.com/rubykube/coinhub)

### Barong

Barong is a KYC OAuth 2.0 provider.
Barong replace the KyC, 2FA, phone verification from legacy Peatio.

Barong manage roles and KyC level across all applications from the RKCP.
It's easy to extend by using the EventAPI or REST API.

[Barong project](https://github.com/rubykube/barong)

### Cryptobase

Cryptobase is a base boilerplate Angular/React/Vue.js implementation of the Peatio frontend.
Unfortunately, we don't have an open-source implementation yet.

### Arke

Arke is the missing tool for connecting a liquidity network on your exchange.
Arke is an Open-Source Crypto-Currency Arbitrage platform.

## Stage and QA Environment

We recommend deploying using kite a "stage" environment in which you need to pull newest containers
from the RKCP distribution and run integration testing with your own components.

We recommend using the following namespaces:
 * `stage` will hold latest containers
 * `platform-tools` will run a Jenkins helm chart for test automation
 * `feature-name` namespace for a single micro-service deployment which can use stage micro-services as backend for RC testing

## Production Environment

In production environment it is recommended that Vault deployment is hardened in an isolated VM, and make sure most dev/ops cannot access nor administer Vault.

Make sure all wallets have multi-signature and offload regularly on cold wallets.
Do not leave seeds, private keys or passphrase at the reach of developers, system administrators and eventuals hackers.
