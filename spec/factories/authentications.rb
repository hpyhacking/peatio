# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :authentication do
    provider 'MyString'
    uid 'MyString'
    secret 'MyString'
    member_id 1
  end
end
