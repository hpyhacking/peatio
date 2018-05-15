# encoding: UTF-8
# frozen_string_literal: true

RSpec::Matchers.define :be_d do |expected|
  match do |actual|
    if expected.is_a? BigDecimal
      actual.to_d == expected
    elsif expected.is_a? String
      actual.to_d == expected.to_d
    else
      raise "not support type #{expected.class}"
    end
  end

  failure_message do |actual|
    "expected #{actual} would be of #{expected}"
  end
end
