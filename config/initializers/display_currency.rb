# encoding: UTF-8
# frozen_string_literal: true

ENV['DISPLAY_CURRENCY'].tap do |ccy|
  if ccy.blank? || ccy.downcase != ccy
    raise ArgumentError, 'The value of DISPLAY_CURRENCY is not specified or is invalid (should be lowercase).'
  end
end
