module Deposits
  class Bitsharesx < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable

    def blockchain_url
      currency_obj.blockchain_url(blockid)
    end

  end
end
