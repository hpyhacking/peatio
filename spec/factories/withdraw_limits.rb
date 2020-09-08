# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :withdraw_limit do
    group { 'any' }
    kyc_level { 'any' }
    limit_24_hour { 9999.to_d }
    limit_1_month { 999_999.to_d }
  end
end
