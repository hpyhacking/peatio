module Deposits
  class Protoshare < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable
  end
end
