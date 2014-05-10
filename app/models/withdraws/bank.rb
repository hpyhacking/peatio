module Withdraws
  class Bank < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Bankable
  end
end
