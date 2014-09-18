module Withdraws
  class Bitsharesx < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable
    include ::FundSourceable

    validates :sum, presence: true, numericality: {greater_than: 0.00001}, on: :create

    def set_fee
      #self.fee = 1.to_d
    end

  end
end
