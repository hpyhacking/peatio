# encoding: UTF-8
# frozen_string_literal: true

class String
  # Similar to how ActiveRecord does. See lib/active_record/type/decimal.rb
  def to_d
    str_decimal = delete_suffix('.')
    return BigDecimal(0) if str_decimal.blank?

    BigDecimal(str_decimal)
  end
end
