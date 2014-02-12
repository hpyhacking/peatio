class CurrencyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    currency = eval Figaro.env.currency
    key = "#{record.bid}_#{record.ask}"

    precision = currency[key]['precision'][attribute.to_s]

    unless BigDecimal.new(value) % BigDecimal.new(precision.to_s) == 0
      record.errors[attribute] << (options[:message] || I18n.t('activemodel.errors.messages.orders.precision', p: precision))
    end

    range = currency[key]['range'][attribute.to_s]
    range = Range.new(*range)

    unless range.cover? value.to_f
      record.errors[attribute] << (options[:message] || I18n.t('activemodel.errors.messages.orders.price', l: range.min, h: range.max))
    end

    range = currency[key]['range']['sum']
    range = Range.new(*range)
    sum = BigDecimal.new(record.price) * BigDecimal.new(record.volume)

    unless range.cover? sum.to_f
      record.errors[attribute] << (options[:message] || I18n.t('activemodel.errors.messages.orders.sum', l: range.min, h: range.max))
    end
  end
end

