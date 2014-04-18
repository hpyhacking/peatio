module Deposits
  class Bank < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Bankable

    validates_presence_of :fund_extra, :fund_uid, :amount
    validates_numericality_of :amount, greater_than_or_equal_to: 100
  end
end
