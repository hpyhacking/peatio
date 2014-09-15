class SystemMailer < BaseMailer

  default from: ENV["SYSTEM_MAIL_FROM"],
          to:   ENV["SYSTEM_MAIL_TO"]

  def balance_warning(amount, balance)
    @amount = amount
    @balance = balance
    mail :subject => "satoshi balance warning"
  end

  def trade_execute_error(payload, error, backtrace)
    @payload   = payload
    @error     = error
    @backtrace = backtrace
    mail subject: "Trade execute error: #{@error}"
  end

end
