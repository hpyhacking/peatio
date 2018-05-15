# encoding: UTF-8
# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :authentication do
    provider 'MyString'
    uid 'MyString'
    token 'MyString'
    member_id 1
  end
end
