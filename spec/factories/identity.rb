FactoryBot.define do
  factory :identity do
    email { Faker::Internet.email }
    password { 'Password123' }
    password_confirmation { 'Password123' }
    is_active true

    trait :deactive do
      is_active false
    end
  end
end
