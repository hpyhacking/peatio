FactoryGirl.define do
  factory :id_document do
    category  :id_card
    name { ["太太", "张三", "李四", "王二麻子"].sample }
    sn { Faker::Number.number(15).to_s }
    verified true
  end
end
