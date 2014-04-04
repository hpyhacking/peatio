FactoryGirl.define do
  factory :member do
    email { Faker::Internet.email }
    name { Faker::Name.name }

    trait :activated do
      activated true
    end

    trait :verified do
      after :create do |member|
        create :id_document, member: member
      end
    end

    factory :activated_member, traits: [:activated]
    factory :verified_member, traits: [:activated, :verified]
  end
end
