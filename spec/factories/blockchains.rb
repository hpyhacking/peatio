# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :blockchain do
    trait 'xrp-testnet' do
      key                     'xrp-testnet'
      name                    'Ripple Testnet'
      client                  'ripple'
      server                  'https://s.altnet.rippletest.net:51234'
      height                  40280751
      min_confirmations       1
      explorer_address        ''
      explorer_transaction    ''
      status                  'active'
    end

    trait 'eth-rinkeby' do
      key                     'eth-rinkeby'
      name                    'Ethereum Rinkeby'
      client                  'ethereum'
      server                  'http://127.0.0.1:8545'
      height                  2500000
      min_confirmations       6
      explorer_address        'https://etherscan.io/address/#{address}'
      explorer_transaction    'https://etherscan.io/tx/#{txid}'
      status                  'active'
    end

    trait 'eth-mainet' do
      key                     'eth-mainet'
      name                    'Ethereum Mainet'
      client                  'ethereum'
      server                  'http://127.0.0.1:8545'
      height                  2500000
      min_confirmations       4
      explorer_address        'https://etherscan.io/address/#{address}'
      explorer_transaction    'https://etherscan.io/tx/#{txid}'
      status                  'disabled'
    end

    trait 'btc-testnet' do
      key                     'btc-testnet'
      name                    'Bitcoin Testnet'
      client                  'bitcoin'
      server                  'http://127.0.0.1:18332'
      height                  1350000
      min_confirmations       1
      explorer_address        ' https://blockchain.info/address/#{address}'
      explorer_transaction    'https://blockchain.info/tx/#{txid}'
      status                  'active'
    end

    trait 'ltc-testnet' do
      key                     'ltc-testnet'
      name                    'Litecoin Testnet'
      client                  'litecoin'
      server                  'http://127.0.0.1:17732'
      height                  1350000
      min_confirmations       1
      explorer_address        'https://live.blockcypher.com/ltc/address/#{address}'
      explorer_transaction    'https://live.blockcypher.com/ltc/tx/#{txid}'
      status                  'active'
    end

    trait 'dash-testnet' do
      key                     'dash-testnet'
      name                    'Dash Testnet'
      client                  'dash'
      server                  'http://127.0.0.1:19998'
      height                  1350000
      min_confirmations       1
      explorer_address        'https://live.blockcypher.com/dash/address/#{address}'
      explorer_transaction    'https://live.blockcypher.com/dash/tx/#{txid}'
      status                  'active'
    end

    trait 'bch-testnet' do
      key                     'bch-testnet'
      name                    'BitcoinCash Testnet'
      client                  'bitcoincash'
      server                  'http://127.0.0.1:18332'
      height                  1350000
      min_confirmations       1
      explorer_address        'https://live.blockcypher.com/bch/address/#{address}'
      explorer_transaction    'https://live.blockcypher.com/bch/tx/#{txid}'
      status                  'active'
    end

    trait 'xrp-testnet' do
      key                     'xrp-testnet'
      name                    'Ripple Testnet'
      client                  'ripple'
      server                  'http://127.0.0.1:5005'
      height                  1350000
      min_confirmations       1
      explorer_address        'https://bithomp.com/explorer/#{address}'
      explorer_transaction    'https://bithomp.com/explorer/#{txid}'
      status                  'active'
    end
  end
end
