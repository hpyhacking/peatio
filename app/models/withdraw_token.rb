class WithdrawToken < Token
  set_callback :confirmed, :after, :confirm_withdraw

  private
  def confirm_withdraw
    tokenable.active
  end
end
