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

    trait :btc do
      code                 'btc'
      symbol               '฿'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 0.1
      withdraw_fee         0.01
      options \
        api_client:               'BTC',
        json_rpc_endpoint:        'http://127.0.0.1:18332',
        wallet_url_template:      'https://testnet.blockchain.info/address/#{address}',
        transaction_url_template: 'https://testnet.blockchain.info/tx/#{txid}',
        deposit_confirmations:    1
    end

    trait :dash do
      code                 'dash'
      symbol               'Đ'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.02
      options \
        api_client:            'DASH',
        json_rpc_endpoint:     'http://127.0.0.1:19999',
        deposit_confirmations: 1
    end

    trait :eth do
      code                 'eth'
      symbol               'Ξ'
      type                 'coin'
      base_factor          1_000_000_000_000_000_000
      quick_withdraw_limit 1
      withdraw_fee         0.025
      options \
        api_client:               'ETH',
        json_rpc_endpoint:        'http://127.0.0.1:8545',
        wallet_url_template:      'https://rinkeby.etherscan.io/address/#{address}',
        transaction_url_template: 'https://rinkeby.etherscan.io/tx/#{txid}',
        deposit_confirmations:    1
    end

    trait :xrp do
      code                 'xrp'
      symbol               'ꭆ'
      type                 'coin'
      base_factor          1_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.015
      options \
        api_client:               'XRP',
        json_rpc_endpoint:        'http://127.0.0.1:5005',
        wallet_url_template:      'https://bithomp.com/explorer/#{txid}',
        transaction_url_template: 'https://bithomp.com/explorer/#{address}',
        deposit_confirmations:    1
    end
  end
end
