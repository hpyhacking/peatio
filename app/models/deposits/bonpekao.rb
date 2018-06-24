module Deposits
  class Bonpekao < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable
  end
end
