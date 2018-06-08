# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :member do
    email { Faker::Internet.email }
    level 0

    trait :level_3 do
      level 3
    end

    trait :level_2 do
      level 2
    end

    trait :level_1 do
      level 1
    end

    trait :level_0 do
      level 0
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
