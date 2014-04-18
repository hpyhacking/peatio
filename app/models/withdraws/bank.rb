module Withdraws
  class Bank < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Bankable
    validates :sum, presence: true, numericality: {greater_than: 1}, on: :create
  end
end
