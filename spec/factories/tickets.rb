# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticket do
    content "MyText"
    state "MyString"
    author_id 1
  end
end
