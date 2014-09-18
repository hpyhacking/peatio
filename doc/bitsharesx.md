# BitShares X

#### Daemon Installation

sudo apt-get update
sudo apt-get install cmake git libreadline-dev uuid-dev g++ libdb++-dev libdb-dev zip libssl-dev openssl build-essential python-dev autotools-dev libicu-dev libbz2-dev libboost-dev libboost-all-dev

git clone git://github.com/dacsunlimited/bitsharesx.git
cd bitsharesx
git submodule init
git submodule update
export CC=clang CXX=clang++
cmake .
make

Ref: https://github.com/dacsunlimited/bitsharesx/blob/master/BUILD_UBUNTU.md

#### Daemon Configuration

Enable rpc in `data/config.json`:

```
  "rpc": {
    "enable": true,
    "rpc_user": "btsx",
    "rpc_password": "btsxhelloworld",
    "rpc_endpoint": "127.0.0.1:20149",
    "httpd_endpoint": "127.0.0.1:20150",
    "htdocs": "./htdocs"
  }
```

#### Daemon Run

First run:

```
  ./programs/client/bitshares_client --data-dir data

  # create account in console
  >>> wallet_account_create <deposit account>
```

Run with startup script:

```
  ./programs/client/bitshares_client --data-dir data --input-log startup
```

startup script:

```
  >>> wallet_open <wallet name>
  >>> wallet_unlock 999999999 <passphrase>
```
