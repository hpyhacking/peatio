FactoryGirl.define do
  factory :member do
    name { Faker::Name.name }
    alipay { 'aplipay!' }
  end
end
