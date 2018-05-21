# encoding: UTF-8
# frozen_string_literal: true

class NilClass
  def to_d
    BigDecimal(0)
  end
end
