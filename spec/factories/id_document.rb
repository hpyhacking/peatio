FactoryGirl.define do
  factory :id_document do
    category  :id_card
    name { Faker::Name.name }
    sn { Faker::Number.number(15).to_s }
    verified true
  end
end
