# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :currency do
    trait :usd do
      code                 'usd'
      symbol               '$'
      type                 'fiat'
      precision            2
      quick_withdraw_limit 10
      withdraw_fee         0.1
    end

    trait :eur do
      code                 'eur'
      symbol               '€'
      type                 'fiat'
      precision            8
      quick_withdraw_limit 1000
      withdraw_fee         0.1
      enabled              false
    end

    trait :btc do
      blockchain_key       'btc-testnet'
      code                 'btc'
      symbol               '฿'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 0.1
      withdraw_fee         0.01
      options \
        api_client:                       'BTC',
        json_rpc_endpoint:                'http://127.0.0.1:18332',
        min_confirmations:                2,
        case_sensitive:                   true,
        supports_hd_protocol:             true,
        allow_multiple_deposit_addresses: true
    end

    trait :dash do
      blockchain_key       'dash-testnet'
      code                 'dash'
      symbol               'Đ'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.02
      options \
        api_client:                       'DASH',
        json_rpc_endpoint:                'http://127.0.0.1:19999',
        min_confirmations:                1,
        case_sensitive:                   true,
        supports_hd_protocol:             true,
        allow_multiple_deposit_addresses: true
    end

    trait :eth do
      blockchain_key       'eth-rinkeby'
      code                 'eth'
      symbol               'Ξ'
      type                 'coin'
      base_factor          1_000_000_000_000_000_000
      quick_withdraw_limit 1
      withdraw_fee         0.025
      options \
        api_client:                       'ETH',
        json_rpc_endpoint:                'http://127.0.0.1:8545',
        min_confirmations:                1,
        case_sensitive:                   false,
        supports_hd_protocol:             false,
        allow_multiple_deposit_addresses: false
    end

    trait :xrp do
      code                 'xrp'
      symbol               'ꭆ'
      type                 'coin'
      base_factor          1_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.015
      options \
        api_client:                       'XRP',
        json_rpc_endpoint:                'http://127.0.0.1:5005',
        min_confirmations:                1,
        case_sensitive:                   true,
        supports_hd_protocol:             false,
        allow_multiple_deposit_addresses: false
    end

    trait :trst do
      blockchain_key       'eth-rinkeby'
      code                 'trst'
      symbol               'Ξ'
      type                 'coin'
      base_factor          1_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.025
      options \
        api_client:                       'ERC20',
        json_rpc_endpoint:                'http://127.0.0.1:8545',
        erc20_contract_address:           '0x87099adD3bCC0821B5b151307c147215F839a110',
        min_confirmations:                1,
        case_sensitive:                   false,
        supports_hd_protocol:             false,
        allow_multiple_deposit_addresses: false
    end

    trait :bch do
      blockchain_key       'bch-testnet'
      code                 'bch'
      symbol               '฿'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 1
      withdraw_fee         0
      options \
        api_client:                       'BCH',
        json_rpc_endpoint:                'http://127.0.0.1:48977',
        min_confirmations:                1,
        case_sensitive:                   true,
        supports_cash_addr_format:        true,
        supports_hd_protocol:             true,
        allow_multiple_deposit_addresses: true
    end

    trait :ltc do
      blockchain_key       'ltc-testnet'
      code                 'ltc'
      symbol               'Ł'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.02
      options \
        api_client:                       'LTC',
        json_rpc_endpoint:                'http://127.0.0.1:17732',
        min_confirmations:                1,
        case_sensitive:                   true,
        supports_hd_protocol:             true,
        allow_multiple_deposit_addresses: true
    end
  end
end
