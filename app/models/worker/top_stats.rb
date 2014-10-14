module Worker
  class TopStats < Stats

    def initialize(market)
      super()
      @market = market
    end

    def run
      [60, 1440, 10080].each do |period|
        collect period
      end
      Rails.logger.info "#{self.to_s} collected."
    end

    def to_s
      "#{self.class.name} (#{@market.id})"
    end

    def key_for(period)
      "peatio:stats:top:#{@market.id}:#{period}"
    end

    def point_n(from, period)
      if (from+period.minutes) < (Time.now-period.minutes)
        [from.to_i, [], []]
      else
        to = from + period.minutes
        trades = Trade.with_currency(@market.id).where(created_at: from..to).pluck(:ask_member_id, :bid_member_id, :volume)

        user_trades = Hash.new {|h, k| h[k] = 0 }
        user_volume = Hash.new {|h, k| h[k] = 0 }
        trades.each do |t|
          if t[0] == t[1] # ask_member_id == bid_member_id
            user_trades[t[0]] += 1
            user_volume[t[0]] += t[2]
          else
            user_trades[t[0]] += 1
            user_trades[t[1]] += 1
            user_volume[t[0]] += t[2]
            user_volume[t[1]] += t[2]
          end
        end

        top_trades_users = user_trades.to_a.sort_by {|ut| -ut.last }[0, 50]
        top_volume_users = user_volume.to_a.sort_by {|uv| -uv.last }[0, 50]
        [from.to_i, top_trades_users, top_volume_users]
      end
    end

  end
end
