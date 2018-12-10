module API::V2
  module Account
    class Mount < Grape::API

      before { authenticate! }

      mount Account::Withdraws
      mount Account::Deposits
      mount Account::Balances
    end
  end
end
