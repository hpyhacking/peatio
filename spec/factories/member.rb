FactoryGirl.define do
  factory :member do
    name { Faker::Name.name }
  end
end
