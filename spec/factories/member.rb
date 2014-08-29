FactoryGirl.define do
  factory :member, aliases: [:author] do
    email { Faker::Internet.email }
    phone_number { Faker::Number.number(12).to_s }

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
        id_doc = member.id_document
        id_doc.update attributes_for(:id_document)
        id_doc.submit!
        id_doc.approve!
      end
    end

    trait :phone_number_verified do
      phone_number_verified true
    end

    trait :admin do
      after :create do |member|
        ENV['ADMIN'] = (Member.admins << member.email).join(',')
      end
    end

    factory :activated_member, traits: [:activated]
    factory :verified_member, traits: [:activated, :verified]
    factory :verified_phone_number, traits: [:activated, :phone_number_verified]
    factory :admin_member, traits: [:admin]
  end
end
