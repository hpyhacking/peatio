module MailHelper

  def pretty_currency(amount, currency)
    if amount
      if amount == 0
        '0'
      else
        "%.2f %s" % [amount, currency.code.upcase]
      end
    else
      '-'
    end
  end

  def pretty_change(change, direction=nil)
    direction ||= change
    if change.nil? || change == '-'
      '-'
    elsif direction > 0
      "#{change} <span style='color:#0F0;'>&#11014;</span>".html_safe
    elsif direction < 0
      "#{change} <span style='color:#F00;'>&#11015;</span>".html_safe
    else
      change
    end
  end

  def pretty_percentage(value)
    if value
      "%.2f%%" % (value*100)
    else
      '-'
    end
  end

end
