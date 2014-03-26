RSpec::Matchers.define :be_d do |expected|
  match do |actual|
    if actual.respond_to?(:text)
      actual = actual.text unless actual.text.empty?
    end

    if actual.respond_to?(:value)
      actual = actual.value unless actual.value.empty?
    end

    if expected.kind_of? BigDecimal
      actual.to_d == expected
    elsif expected.kind_of? String
      actual.to_d == expected.to_d
    else
      raise "not support type #{expected.class}"
    end
  end

  failure_message_for_should do |actual|
    "expected #{actual.to_s} would be of #{expected.to_s}"
  end
end
