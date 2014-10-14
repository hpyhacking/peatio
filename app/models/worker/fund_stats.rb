module Worker
  class FundStats < Stats

    def initialize(currency)
      super()
      @currency = currency
    end

    def to_s
      "#{self.class.name} (#{@currency.code})"
    end

    def key_for(period)
      "peatio:stats:funds:#{@currency.id}:#{period}"
    end

    def point_1(from)
      to = from + 1.minute
      deposits = Deposit.with_aasm_state(:accepted).where(currency: @currency.id, created_at: from..to).pluck(:amount)
      withdraws = Withdraw.with_aasm_state(:done).where(currency: @currency.id, created_at: from..to).pluck(:amount)
      [from.to_i, deposits.size, deposits.sum.to_f, withdraws.size, withdraws.sum.to_f]
    end

  end
end
