class WithdrawChannelBank < WithdrawChannel
  def calc_fee!(withdraw)
    return if withdraw.sum.nil?
    fixed ||= 2
    self.fee ||= '0.003'
    withdraw.sum = [min, withdraw.sum].max.to_d.round(fixed, :floor)
    withdraw.fee = (withdraw.sum * fee.to_d).round(fixed, :floor)
  end
end
