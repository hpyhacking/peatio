module Withdraws
  class Dogecoin < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable

    validates :sum, presence: true, numericality: {greater_than: 1}, on: :create

    def set_fee
      self.fee = 1.to_d
    end
  end
end
