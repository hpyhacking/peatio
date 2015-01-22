class WithdrawMailer < BaseMailer

  def withdraw_submitted(withdraw_id)
    set_mail(withdraw_id)
  end

  def withdraw_processing(withdraw_id)
    set_mail(withdraw_id)
  end

  def withdraw_done(withdraw_id)
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
