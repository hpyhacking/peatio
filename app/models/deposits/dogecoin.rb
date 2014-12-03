module Deposits
  class Dogecoin < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable
  end
end
