# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :comment do
    sequence(:content) { |n| "Content #{n}" }
    ticket
    author
  end
end
