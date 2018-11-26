# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do

    trait :eth_deposit do
      currency_id        { 'eth' }
      blockchain_key     { 'eth-rinkeby' }
      name               { 'Ethereum Deposit Wallet' }
      address            { '0x828058628DF254Ebf252e0b1b5393D1DED91E369' }
      kind               { 'deposit' }
      max_balance        { 0.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'geth' }
      uri                { 'http://127.0.0.1:8545' }
      secret             { 'changeme' }
    end

    trait :eth_hot do
      currency_id        { 'eth' }
      blockchain_key     { 'eth-rinkeby' }
      name               { 'Ethereum Hot Wallet' }
      address            { '0xb6a61c43DAe37c0890936D720DC42b5CBda990F9' }
      kind               { 'hot' }
      max_balance        { 100.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'geth' }
      uri                { 'http://127.0.0.1:8545' }
      secret             { 'changeme' }
    end

    trait :eth_warm do
      currency_id        { 'eth' }
      blockchain_key     { 'eth-rinkeby' }
      name               { 'Ethereum Warm Wallet' }
      address            { '0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C' }
      kind               { 'warm' }
      max_balance        { 1000.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'geth' }
      uri                { 'http://127.0.0.1:8545' }
      secret             { 'changeme' }
    end

    trait :eth_cold do
      currency_id        { 'eth' }
      blockchain_key     { 'eth-rinkeby' }
      name               { 'Ethereum Cold Wallet' }
      address            { '0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C' }
      kind               { 'cold' }
      max_balance        { 1000.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'geth' }
      uri                { 'http://127.0.0.1:8545' }
      secret             { 'changeme' }
    end

    trait :eth_fee do
      currency_id        { 'eth' }
      blockchain_key     { 'eth-rinkeby' }
      name               { 'Ethereum Fee Wallet' }
      address            { '0x45a31b15a2ab8a8477375b36b6f5a0c63733dce8' }
      kind               { 'fee' }
      max_balance        { 1000.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'geth' }
      uri                { 'http://127.0.0.1:8545' }
      secret             { 'changeme' }
    end

    trait :trst_deposit do
      currency_id        { 'trst' }
      blockchain_key     { 'eth-rinkeby' }
      name               { 'Trust Coin Deposit Wallet' }
      address            { '0x828058628DF254Ebf252e0b1b5393D1DED91E369' }
      kind               { 'deposit' }
      max_balance        { 0.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'geth' }
      uri                { 'http://127.0.0.1:8545' }
      secret             { 'changeme' }
    end

    trait :trst_hot do
      currency_id        { 'trst' }
      blockchain_key     { 'eth-rinkeby' }
      name               { 'Trust Coin Hot Wallet' }
      address            { '0xb6a61c43DAe37c0890936D720DC42b5CBda990F9' }
      kind               { 'hot' }
      max_balance        { 100.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'geth' }
      uri                { 'http://127.0.0.1:8545' }
      secret             { 'changeme' }
    end

    trait :btc_deposit do
      currency_id        { 'btc' }
      blockchain_key     { 'btc-testnet' }
      name               { 'Bitcoin Deposit Wallet' }
      address            { '3DX3Ak4751ckkoTFbYSY9FEQ6B7mJ4furT' }
      kind               { 'deposit' }
      max_balance        { 0.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'bitcoind' }
      uri                { 'http://127.0.0.1:18332' }
      secret             { 'changeme' }
    end

    trait :btc_hot do
      currency_id        { 'btc' }
      blockchain_key     { 'btc-testnet' }
      name               { 'Bitcoin Hot Wallet' }
      address            { '3NwYr8JxjHG2MBkgdBiHCxStSWDzyjS5U8' }
      kind               { 'hot' }
      max_balance        { 500.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'bitcoind' }
      uri                { 'http://127.0.0.1:18332' }
      secret             { 'changeme' }
    end

     trait :xrp_deposit do
      currency_id        { 'xrp' }
      blockchain_key     { 'xrp-testnet' }
      name               { 'Ripple Deposit Wallet' }
      address            { 'rN3J1yMz2PCGievtS2XTEgkrmdHiJgzb5Y?dt=917590223' }
      kind               { 'deposit' }
      max_balance        { 0.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'rippled' }
      uri                { 'http://127.0.0.1:5005' }
      secret             { 'changeme' }
    end

    trait :xrp_hot do
      currency_id        { 'xrp' }
      blockchain_key     { 'xrp-testnet' }
      name               { 'Ripple Hot Wallet' }
      address            { 'r4kpJtnx4goLYXoRdi7mbkRpZ9Xpx2RyPN' }
      kind               { 'hot' }
      max_balance        { 100.0 }
      nsig               { 2 }
      status             { 'active' }
      gateway            { 'rippled' }
      uri                { 'http://127.0.0.1:5005' }
      secret             { 'changeme' }
    end

    trait :bch_deposit do
      currency_id       { 'bch' }
      blockchain_key    { 'bch-testnet' }
      name              { 'Bitcoincash Deposit Wallet' }
      address           { 'mqF8Bsv2rHThg4cVDgwYcnEYNDWKi4spD7' }
      kind              { 'deposit' }
      max_balance       { 0.0 }
      nsig              { 1 }
      status            { 'active' }
      gateway           { 'bitcoincashd' }
      uri               { 'http://127.0.0.1:18332' }
      secret            { 'changeme' }
    end

    trait :bch_hot do
      currency_id       { 'bch' }
      blockchain_key    { 'bch-testnet' }
      name              { 'Bitcoincash Hot Wallet' }
      address           { 'n2stP7w1DpSh7N1PzJh7eGjgCk3eTF3DMC' }
      kind              { 'hot' }
      max_balance       { 100.0 }
      nsig              { 1 }
      status            { 'active' }
      gateway           { 'bitcoincashd' }
      uri               { 'http://127.0.0.1:18332' }
      secret            { 'changeme' }
    end

    trait :dash_deposit do
      currency_id       { 'dash' }
      blockchain_key    { 'dash-testnet' }
      name              { 'Dash Deposit Wallet' }
      address           { 'yVcZM6oUjfwrREm2CDb9G8BMHwwm5o5UsL' }
      kind              { 'deposit' }
      max_balance       { 0.0 }
      nsig              { 1 }
      status            { 'active' }
      gateway           { 'dashd' }
      uri               { 'http://127.0.0.1:19998' }
      secret            { 'changeme' }
    end

    trait :dash_hot do
      currency_id       { 'dash' }
      blockchain_key    { 'dash-testnet' }
      name              { 'Dash Hot Wallet' }
      address           { 'yborj44WhothaX6vwoMhRMjkq1xELhAWQp' }
      kind              { 'hot' }
      max_balance       { 100.0 }
      nsig              { 1 }
      status            { 'active' }
      gateway           { 'dashd' }
      uri               { 'http://127.0.0.1:19998' }
      secret            { 'changeme' }
    end

    trait :ltc_deposit do
      currency_id       { 'ltc' }
      blockchain_key    { 'ltc-testnet' }
      name              { 'Litecoin Deposit Wallet' }
      address           { 'QcM2zjgbaXbH26utxnNFge24A1BnDgSgcU' }
      kind              { 'deposit' }
      max_balance       { 0.0 }
      nsig              { 1 }
      status            { 'active' }
      gateway           { 'litecoind' }
      uri               { 'http://127.0.0.1:17732' }
    end

    trait :ltc_hot do
      currency_id       { 'ltc' }
      blockchain_key    { 'ltc-testnet' }
      name              { 'Litecoin Hot Wallet' }
      address           { 'Qc2BM7gp8mKgJPPxLAadLAHteNQwhFwwuf' }
      kind              { 'hot' }
      max_balance       { 100.0 }
      nsig              { 1 }
      status            { 'active' }
      gateway           { 'litecoind' }
      uri               { 'http://127.0.0.1:17732' }
    end
  end
end
