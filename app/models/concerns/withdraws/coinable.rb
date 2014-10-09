module Withdraws
  module Coinable
    extend ActiveSupport::Concern

    def set_fee
      self.fee = "0.0001".to_d
    end

    def blockchain_url
      currency_obj.blockchain_url(txid)
    end

  end
end

