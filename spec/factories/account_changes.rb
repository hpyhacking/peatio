# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account_change do
    account_id 1
    origin "9.99"
    change "9.99"
    reason "MyString"
  end
end
