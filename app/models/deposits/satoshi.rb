module Deposits
  class Satoshi < ::Deposit
    include ::DepositCoinable
    include ::AasmStateI18nable
  end
end
