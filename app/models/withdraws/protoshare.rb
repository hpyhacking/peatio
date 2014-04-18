module Withdraws
  class Protoshare < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable
  end
end
