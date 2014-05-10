module Withdraws
  class Dogecoin < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable

    validates :sum, presence: true, numericality: {greater_than: 1}, on: :create
  end
end
