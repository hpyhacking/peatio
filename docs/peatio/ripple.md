# Adding Ripple Support

_For using ripple at this stage, we don't need `rippled` installed._

## Configuration

First, you will need to update your configuration files according to new _.example_ files (`config/currencies.yml` and `config/markets.yml`).

In `config/currencies.yml` change the `rpc` url (for testnet it's `https://api.altnet.rippletest.net:51234`). To make XRP payments work, we need to store a secret for every account, so make sure you've added one for ripple in `config/currencies.yml` (you can get a XRP testnet account [here](https://ripple.com/build/xrp-test-net/)).
