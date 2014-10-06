class WithdrawMailer < BaseMailer

  def submitted(withdraw_id)
    set_mail(withdraw_id)
  end

  def processing(withdraw_id)
    set_mail(withdraw_id)
  end

  def done(withdraw_id)
    set_mail(withdraw_id)
  end

  def withdraw_state(withdraw_id)
    set_mail(withdraw_id)
  end

  private

  def set_mail(withdraw_id)
    @withdraw = Withdraw.find withdraw_id
    mail to: @withdraw.member.email
  end

end
