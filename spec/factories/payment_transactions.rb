# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_transaction do
    tx_id "MyString"
    amount "9.99"
    confirmation 1
    address "MyString"
  end
end
