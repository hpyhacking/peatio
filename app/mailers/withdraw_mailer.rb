class WithdrawMailer < ActionMailer::Base
  include AMQPQueue::Mailer

  default from: ENV['SYSTEM_MAIL_FROM']

  def withdraw_state(withdraw_id)
    @withdraw = Withdraw.find withdraw_id
    mail :to => @withdraw.member.email
  end
end
