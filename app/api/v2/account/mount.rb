module API::V2
  module Account
    class Mount < Grape::API

      before { authenticate! }
      before { set_ets_context! }

      mount Account::Balances
      mount Account::Deposits
      mount Account::Beneficiaries
      mount Account::Withdraws
    end
  end
end
