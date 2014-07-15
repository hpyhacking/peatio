FactoryGirl.define do
  factory :member, aliases: [:author] do
    email { Faker::Internet.email }
    name { Faker::Name.name }

    trait :activated do
      activated true
    end

    trait :two_factor_activated do
      after :create do |member|
        member.two_factors.create \
          type: 'TwoFactor::App',
          activated: true
      end
    end

    trait :two_factor_inactivated do
      after :create do |member|
        member.two_factors.create \
          type: 'TwoFactor::App',
          activated: false
      end
    end

    trait :verified do
      after :create do |member|
        create :id_document, member: member
      end
    end

    trait :phone_number_verified do
      phone_number_verified true
    end

    factory :activated_member, traits: [:activated]
    factory :verified_member, traits: [:activated, :verified]
    factory :verified_phone_number, traits: [:activated, :phone_number_verified]
  end
end
