# BitShares X

#### Daemon Installation

git clone git://github.com/dacsunlimited/bitsharesx.git
cd bitsharesx
git submodule init
git submodule update
export CC=clang CXX=clang++
cmake .
make

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
