class WithdrawChannelBank < WithdrawChannel
  def calc_fee!(withdraw)
    fixed ||= 2
    fee ||= '0.003'
    withdraw.sum = [min, withdraw.sum].max.to_d.round(fixed, :floor)
    withdraw.fee = (withdraw.sum * fee.to_d).round(fixed, :floor)
  end
end
