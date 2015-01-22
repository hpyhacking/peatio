class DepositMailer < BaseMailer

  def deposit_accepted(deposit_id)
    @deposit = Deposit.find deposit_id
    mail to: @deposit.member.email
  end

end
