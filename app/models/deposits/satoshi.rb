module Deposits
  class Satoshi < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable
  end
end
