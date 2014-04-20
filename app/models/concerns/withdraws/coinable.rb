module Withdraws
  module Coinable
    extend ActiveSupport::Concern

    included do
      validate :validate_address
    end

    def set_fee
      self.fee = "0.0001".to_d
    end

    private

    def validate_address
      result = CoinRPC[currency].validateaddress(fund_uid)

      if result[:isvalid] == false
        errors.add(:fund_uid, :invalid)
      elsif (result[:ismine] == true) || PaymentAddress.find_by_address(fund_uid)
        errors.add(:fund_uid, :ismine)
      end
    end
  end
end

