class WithdrawChannelSatoshi < WithdrawChannel
  def calc_fee!(withdraw)
    fixed ||= 8
    fee ||= '0.0005'
    withdraw.sum = withdraw.sum.round(fixed, :floor)
    withdraw.fee = fee.to_d
  end
end
