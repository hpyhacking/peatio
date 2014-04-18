module Withdraws
  class Satoshi < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable
  end
end
