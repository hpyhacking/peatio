module Deposits
  class Bitsharesx < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable

    def memo
      0
    end

    def blockchain_url
      currency_obj.blockchain_url(self[:memo])
    end

  end
end
