module Withdraws
  module Coinable
    extend ActiveSupport::Concern

    def set_fee
      self.fee = "0.0001".to_d
    end

  end
end

