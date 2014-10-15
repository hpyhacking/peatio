class SystemMailer < BaseMailer

  default from: ENV["SYSTEM_MAIL_FROM"],
          to:   ENV["SYSTEM_MAIL_TO"]

  layout 'mailers/system'

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

  def daily_stats(ts, stats, base)
    @stats = stats
    @base  = base
    from   = Time.at(ts)
    to     = Time.at(ts + 1.day - 1)
    mail subject: "Daily Summary (#{from} - #{to})"
  end

end
