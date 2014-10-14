module Worker
  class WalletStats < Stats

    def initialize(currency)
      super()
      @currency = currency
    end

    def run
      collect 60
      Rails.logger.info "#{self.to_s} collected."
    end

    def to_s
      "#{self.class.name} (#{@currency.code})"
    end

    def key_for(period)
      "peatio:stats:wallet:#{@currency.id}"
    end

    def point_n(from, period)
      if (from+period.minutes) < (Time.now-period.minutes)
        [from.to_i, 0, 0, 0]
      else
        balance = Account.balance_sum(@currency.code)
        locked  = Account.locked_sum(@currency.code)
        [from.to_i, balance.to_f, locked.to_f, (balance+locked).to_f]
      end
    end

  end
end
