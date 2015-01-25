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

  def order_processor_error(payload, error, backtrace)
    @payload   = payload
    @error     = error
    @backtrace = backtrace
    mail subject: "Order processor error: #{@error}"
  end

  def daily_stats(ts, stats, base)
    @stats = stats
    @base  = base

    @changes = {
      assets: Currency.all.map {|c|
        [ c,
          compare(@base['asset_stats'][c.code][1], @stats['asset_stats'][c.code][1]),
          compare(@base['asset_stats'][c.code][0], @stats['asset_stats'][c.code][0])
        ]
      },
      trades: Market.all.map {|m|
        [ m,
          compare(@base['trade_users'][m.id][1], @stats['trade_users'][m.id][1])
        ]
      }
    }

    from   = Time.at(ts)
    to     = Time.at(ts + 1.day - 1)
    mail subject: "Daily Summary (#{from} - #{to})",
         to: ENV['OPERATE_MAIL_TO']
  end

  private

  def compare(before, now)
    if before.nil? || now.nil?
      []
    else
      [ now-before, percentage_compare(before, now) ]
    end
  end

  def percentage_compare(before, now)
    if before == 0
      nil
    else
      (now-before) / before.to_f
    end
  end

end
