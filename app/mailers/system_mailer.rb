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

    @changes = {
      signup: change(@base['member_stats'][1], @stats['member_stats'][1]),
      activation: change(@base['member_stats'][2], @stats['member_stats'][2]),
      wallets: Currency.all.map {|c| [c, change(@base['wallet_stats'][c.code][3], @stats['wallet_stats'][c.code][3]) ] },
      trades: Market.all.map {|m| [m, change(@base['trade_users'][m.id][1], @stats['trade_users'][m.id][1]) ] }
    }

    from   = Time.at(ts)
    to     = Time.at(ts + 1.day - 1)
    mail subject: "Daily Summary (#{from} - #{to})",
         to: ENV['OPERATE_MAIL_TO']
  end

  private

  def change(before, now)
    [now-before, change_in_percent(before, now)]
  end

  def change_in_percent(before, now)
    if before == 0
      'N/A'
    else
      "%.2f%%" % (100*(now-before)/before.to_f)
    end
  end

end
