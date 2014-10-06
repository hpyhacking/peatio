class DepositMailer < BaseMailer

  def accepted(deposit_id)
    @deposit = Deposit.find deposit_id
    mail to: @deposit.member.email
  end

end
