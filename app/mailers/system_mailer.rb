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
      signup: compare(@base['member_stats'][1], @stats['member_stats'][1]),
      activation: compare(@base['member_stats'][2], @stats['member_stats'][2]),
      wallets: Currency.all.map {|c| [c, compare(@base['wallet_stats'][c.code][3], @stats['wallet_stats'][c.code][3]) ] },
      trades: Market.all.map {|m| [m, compare(@base['trade_users'][m.id][1], @stats['trade_users'][m.id][1]) ] }
    }

    from   = Time.at(ts)
    to     = Time.at(ts + 1.day - 1)
    mail subject: "Daily Summary (#{from} - #{to})",
         to: ENV['OPERATE_MAIL_TO']
  end

  private

  def compare(before, now)
    [ pretty_change(now-before), percentage_compare(before, now) ]
  end

  def percentage_compare(before, now)
    if before == 0
      pretty_change '-', 0
    else
      v = 100*(now-before) / before.to_f
      pretty_change("%.2f%%" % v, v)
    end
  end

  def pretty_change(change, direction=nil)
    direction ||= change
    if direction > 0
      "#{change} <span style='color:#0F0;'>&#11014;</span>".html_safe
    elsif direction < 0
      "#{change} <span style='color:#F00;'>&#11015;</span>".html_safe
    else
      change
    end
  end

end
