# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    trait :eth_hot do
      currency_id        'eth'
      blockchain_key     'eth-rinkeby'
      name               'Ethereum Hot Wallet'
      address            '249048804499541338815845805798634312140346616732'
      kind               'hot'
      max_balance        100.0
      nsig               2
      status             'active'
      gateway            'geth'
      uri                'http://127.0.0.1:8545'
      secret             'changeme'
    end

    trait 'eth_warm' do
      currency_id        'eth'
      blockchain_key     'eth-rinkeby'
      name               'Ethereum Warm Wallet'
      address            '0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C'
      kind               'warm'
      nsig               2
      status             'active'
      gateway            'geth'
      uri                'http://127.0.0.1:8545'
      secret             'changeme'
    end

    trait :btc_hot do
      currency_id        'btc'
      blockchain_key     'btc-testnet'
      name               'Bitcoin Hot Wallet'
      address            '0x2b9fBC10EbAeEc28a8Fc10069C0BC29E45eBEB9C'
      kind               'hot'
      nsig               2
      status             'active'
      gateway            'bitcoind'
      uri                'http://127.0.0.1:18332'
      secret             'changeme'
    end
  end

end