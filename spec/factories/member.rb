FactoryBot.define do
  factory :member, aliases: [:author] do
    email { Faker::Internet.email }
    phone_number { Faker::Number.number(12).to_s }

    trait :activated do
      activated true
    end

    trait :verified do
      after :create do |member|
        id_doc = member.id_document
        id_doc.update attributes_for(:id_document)
        id_doc.submit!
        id_doc.approve!
      end
    end

    trait :admin do
      after :create do |member|
        ENV['ADMIN'] = (Member.admins << member.email).join(',')
      end
    end

    factory :activated_member, traits: [:activated]
    factory :verified_member, traits: %i[activated verified]
    factory :admin_member, traits: [:admin]
  end
end
