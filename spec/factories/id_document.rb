FactoryGirl.define do
  factory :id_document do
    name { Faker::Name.name }
    id_document_type :id_card
    id_document_number { Faker::Number.number(15).to_s }
  end
end
