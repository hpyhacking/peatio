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
      "peatio:stats:funds:#{@currency.code}:#{period}"
    end

    def point_1(from)
      to = from + 1.minute
      deposits = Deposit.with_aasm_state(:accepted).where(currency: @currency.id, created_at: from...to).pluck(:amount)
      withdraws = Withdraw.with_aasm_state(:done).where(currency: @currency.id, created_at: from...to).pluck(:amount)
      [from.to_i, deposits.size, deposits.sum.to_f, withdraws.size, withdraws.sum.to_f]
    end

    def point_n(from ,period)
      arr = point_1_set from, period
      deposits_count = arr.sum {|point| point[1] }
      deposits_amount = arr.sum {|point| point[2] }
      withdraws_count = arr.sum {|point| point[3] }
      withdraws_amount = arr.sum {|point| point[4] }
      [from.to_i, deposits_count, deposits_amount, withdraws_count, withdraws_amount]
    end

  end
end
