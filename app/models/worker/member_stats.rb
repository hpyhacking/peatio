module Worker
  class MemberStats < Stats

    def key_for(period)
      "peatio:stats:member:#{period}"
    end

    def to_s
      self.class.name
    end

    def point_1(from)
      to = from + 1.minute
      signup_count = Member.where(created_at: from...to).count
      activate_count = Member.where(activated: true, created_at: from...to).count
      [from.to_i, signup_count, activate_count]
    end

    def point_n(from, period)
      arr = point_1_set from, period
      signup_count = arr.sum {|point| point[1] }
      activate_count = arr.sum(&:last)
      [from.to_i, signup_count, activate_count]
    end

  end
end
