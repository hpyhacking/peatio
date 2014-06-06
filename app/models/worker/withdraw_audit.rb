module Worker
  class WithdrawAudit

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!

      withdraw = Withdraw.find payload[:id]
      if withdraw.coin?
        currency = withdraw.currency
        fund_uid = withdraw.fund_uid
        result = CoinRPC[currency].validateaddress(fund_uid)

        if result[:isvalid] == false
          withdraw.reject!
          return
        elsif (result[:ismine] == true) || PaymentAddress.find_by_address(fund_uid)
          withdraw.reject!
          return
        end
      end

      Withdraw.transaction do
        withdraw = Withdraw.lock.find payload[:id]

        return unless withdraw.submitted?

        if withdraw.account.examine
          withdraw.accept!
        else
          withdraw.mark_suspect!
        end
      end
    end

  end
end
