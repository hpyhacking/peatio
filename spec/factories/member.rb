FactoryBot.define do
  factory :member do
    email { Faker::Internet.email }

    trait :verified do
      after :create do |member|
        id_doc = member.id_document
        id_doc.update!(attributes_for(:id_document))
        id_doc.submit!
        id_doc.approve!
      end
    end

    trait :admin do
      after :create do |member|
        ENV['ADMIN'] = (Member.admins << member.email).join(',')
      end
    end

    factory :verified_member, traits: %i[ verified ]
    factory :admin_member, traits: %i[ admin ]
  end
end
