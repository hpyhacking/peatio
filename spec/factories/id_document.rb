FactoryGirl.define do
  factory :id_document do
    name { ["太太", "张三", "李四", "王二麻子"].sample }
    id_document_type :id_card
    id_document_number { Faker::Number.number(15).to_s }
  end
end
