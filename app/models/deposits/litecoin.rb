module Deposits
  class Litecoin < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable
  end
end
