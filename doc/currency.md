## Deposit

One coin currency may have one coin deposit

* Currency record
* DepositChannel record
* Deposit inheritable model
* Deposit inheritable controller and views

e.g. add litecoin currency and deposit

### add currency config to `config/currencies.yml`

    - id: [uniq number]
      key: litecoin
      code: ltc
      coin: true
      rpc: http://username:password@host:port

### add deposit channel to `config/deposit_channels.yml`

    - id: [uniq number]
      key: litecoin
      min_confirm: 1
      max_confirm: 6

### add deposit inheritable model in `app/models/deposits/litecoin.rb`

    module Deposits
      class Litecoin < ::Deposit
        include ::AasmAbsolutely
        include ::Deposits::Coinable
      end
    end

### add deposit inheritable controller in `app/controllers/private/deposits/litecoins_controller.rb`

    module Private
      module Deposits
        class LitecoinsController < BaseController
          include ::Deposits::CtrlCoinable
        end
      end
    end

### check your routes result have below path helper

    deposits_litecoins POST /deposits/litecoins(.:format) private/deposits/litecoins#create
    new_deposits_litecoin GET /deposits/litecoins/new(.:format) private/deposits/litecoins#new
