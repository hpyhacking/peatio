module Deposits
  class Bank < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Bankable
    include ::FundSourceable

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
