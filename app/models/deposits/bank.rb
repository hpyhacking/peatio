module Deposits
  class Bank < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Bankable
    include ::FundSourceable

    attr_accessor :holder

    validates_presence_of :fund_extra, :fund_uid, :amount
    validates_numericality_of :amount, greater_than_or_equal_to: 100

    def charge!(txid)
      with_lock do
        submit!
        accept!
        touch(:done_at)
        update_attribute(:txid, txid)
      end
    end

  end
end
