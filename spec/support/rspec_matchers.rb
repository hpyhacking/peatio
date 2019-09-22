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

RSpec::Matchers.define :include_api_error do |expected|
  match do |actual|
    raise 'actual doesnt respond to body' unless actual.respond_to?(:body)
    raise 'expected is not a String' unless expected.is_a? String

    errors = JSON.parse(actual.body)['errors']
    !errors.nil? && expected.in?(errors)
  end

  # TODO: Better Error message. Same as in module RSpec::Matchers::BuiltIn::Include
  failure_message do |actual|
    "expected:   #{JSON.parse(actual.body)['errors'].join(',')}\nto include: #{expected}\n"
  end
end

RSpec::Matchers.define :include_ar_error do |attr, expected|
  match do |actual|
    raise 'actual is not subclass of ActiveRecord::Base' unless actual.is_a?(ActiveRecord::Base)

    include(expected).matches?(actual.errors[attr])
  end

  # TODO: Better Error message. Same as in module RSpec::Matchers::BuiltIn::Include
  failure_message do |actual|
    "expected:   #{actual.errors}\nto include: #{expected}\n"
  end
end
