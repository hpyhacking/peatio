FactoryBot.define do
  factory :currency do
    trait :usd do
      key                  'dollar'
      code                 'usd'
      symbol               '$'
      type                 'fiat'
      precision            2
      quick_withdraw_limit 10
    end

    trait :btc do
      key                  'satoshi'
      code                 'btc'
      symbol               '฿'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 0.1
      options \
        api_client:               'BTC',
        json_rpc_endpoint:        'http://127.0.0.1:18332',
        wallet_url_template:      'https://testnet.blockchain.info/address/#{address}',
        transaction_url_template: 'https://testnet.blockchain.info/tx/#{txid}'
    end

    trait :pts do
      key                  'protoshare'
      code                 'pts'
      symbol               'Ρ'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 1000
      options \
        api_client:        'BTC',
        json_rpc_endpoint: 'http://127.0.0.1:11010'
    end

    trait :eth do
      key                  'ethereum'
      code                 'eth'
      symbol               'Ξ'
      type                 'coin'
      base_factor          1_000_000_000_000_000_000
      quick_withdraw_limit 1
      options \
        api_client:               'ETH',
        json_rpc_endpoint:        'http://127.0.0.1:8545',
        wallet_url_template:      'https://rinkeby.etherscan.io/address/#{address}',
        transaction_url_template: 'https://rinkeby.etherscan.io/tx/#{txid}'
    end

    trait :xrp do
      key                  'ripple'
      code                 'xrp'
      symbol               'ꭆ'
      type                 'coin'
      base_factor          1_000_000
      quick_withdraw_limit 1000
      options \
        api_client:               'XRP',
        json_rpc_endpoint:        'http://127.0.0.1:5005',
        wallet_url_template:      'https://bithomp.com/explorer/#{txid}',
        transaction_url_template: 'https://bithomp.com/explorer/#{address}'
    end
  end
end
