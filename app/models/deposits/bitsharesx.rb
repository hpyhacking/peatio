module Deposits
  class Bitsharesx < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Coinable

    validates_uniqueness_of :txid

    def blockchain_url
      currency_obj.blockchain_url(blockid)
    end

  end
end
