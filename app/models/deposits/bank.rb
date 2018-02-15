module Deposits
  class Bank < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Bankable
    include ::FundSourceable

    def charge!(txid)
      with_lock do
        submit!
        accept!
        touch(:done_at)
        update_attribute(:txid, txid)
      end
    end

    def sn=(new_sn)
      self.member = Member.find_by_sn(new_sn)
    end

    def currency=(ccy)
      super(ccy)
      self.account = member&.accounts&.find_by_currency(ccy)
    end
  end
end
