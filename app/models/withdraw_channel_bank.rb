class WithdrawChannelBank < WithdrawChannel
  def calc_fee!(withdraw)
    fix = 2
    withdraw.sum = [min, withdraw.sum].max.to_d.round(fix, 2)
    withdraw.fee = (withdraw.sum * '0.003'.to_d).round(fix, 2)
  end
end
