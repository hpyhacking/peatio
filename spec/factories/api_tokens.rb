# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :api_token do
    member
    scopes 'all'
  end
end
