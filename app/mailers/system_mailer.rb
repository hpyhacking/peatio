class SystemMailer < ActionMailer::Base
  default from: ENV["SYSTEM_MAIL_FROM"], to: ENV["SYSTEM_MAIL_TO"]

  def balance_warning(amount, balance)
    @amount = amount
    @balance = balance
    mail :subject => "satoshi balance warning"
  end
end
