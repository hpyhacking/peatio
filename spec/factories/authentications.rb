# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authentication do
    provider "MyString"
    uid "MyString"
    token "MyString"
    secret "MyString"
    member_id 1
  end
end
