module Deposits
  class Protoshare < ::Deposit
    include ::DepositCoinable
    include ::AasmStateI18nable
  end
end
