module Deposits
  class Bank < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Bankable
    include ::FundSourceable

    attr_accessor :holder

    validates_presence_of :fund_extra, :fund_uid, :amount
    validates_numericality_of :amount, greater_than_or_equal_to: 100

    def charge!(txid)
      ActiveRecord::Base.transaction do
        self.lock!
        self.submit!
        self.accept!
        self.touch(:done_at)
        self.update_attribute(:txid, txid)
      end

    end

  end
end
