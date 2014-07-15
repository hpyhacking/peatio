# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticket do
    sequence(:content) { |n| "Content #{n}" }
    author
  end
end
