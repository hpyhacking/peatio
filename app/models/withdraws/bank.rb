module Withdraws
  class Bank < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Bankable
    validates :sum, presence: true, numericality: {greater_than_or_equal_to: 100}, on: :create
  end
end
