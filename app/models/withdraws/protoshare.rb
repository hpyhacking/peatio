module Withdraws
  class Protoshare < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable

    validates :sum, presence: true, numericality: {greater_than: 0.0001}, on: :create
  end
end
