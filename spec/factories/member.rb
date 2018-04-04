FactoryBot.define do
  factory :member do
    email { Faker::Internet.email }
    level { :unverified }

    trait :verified_identity do
      after(:create) { |member| member.update_column(:level, :identity_verified) }
    end

    trait :verified_phone do
      after(:create) { |member| member.update_column(:level, :phone_verified) }
    end

    trait :verified_email do
      after(:create) { |member| member.update_column(:level, :email_verified) }
    end

    trait :unverified do
      after(:create) { |member| member.update_column(:level, :unverified) }
    end

    trait :admin do
      after :create do |member|
        ENV['ADMIN'] = (Member.admins << member.email).join(',')
      end
    end

    trait :barong do
      after :create do |member|
        member.authentications.build(provider: 'barong', uid: Faker::Internet.password(14, 14)).save!
      end
    end

    factory :admin_member, traits: %i[ admin ]
  end
end
