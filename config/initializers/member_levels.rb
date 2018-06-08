# encoding: UTF-8
# frozen_string_literal: true

%w[ deposit withdraw trading ].each do |ability|
  var = "MINIMUM_MEMBER_LEVEL_FOR_#{ability.upcase}"
  n   = ENV[var]

  if n.blank?
    raise ArgumentError, "The variable #{var} is not set."
  end

  begin
    Integer(n)
  rescue ArgumentError
    raise ArgumentError, "The value of #{var} (#{n.inspect}) is not a valid number."
  end

  if n.to_i < 0 || n.to_i > 99
    raise ArgumentError, "The value of #{var} (#{n.inspect}) must be in range of [0, 99]."
  end
end
