FactoryGirl.define do
  factory :member do
    email { Faker::Internet.email }
    name { Faker::Name.name }

    trait :activated do
      activated true
    end
  end
end
