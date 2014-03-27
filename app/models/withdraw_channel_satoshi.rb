class WithdrawChannelSatoshi < WithdrawChannel
  def calc_fee!(withdraw)
    withdraw.sum = withdraw.sum.round(8, 2)
    withdraw.fee = '0.0005'.to_d
  end
end
