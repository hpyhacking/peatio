module API::V2
  module Account
    class Mount < Grape::API

      before { authenticate! }
      before { set_ets_context! }

      mount Account::Withdraws
      mount Account::Deposits
      mount Account::Balances
    end
  end
end
