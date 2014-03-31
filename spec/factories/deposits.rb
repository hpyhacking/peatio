FactoryGirl.define do
  factory :deposit do
    member { create(:member) }
    account { member.get_account(currency) }
    currency { 'btc' }
    fund_uid { Faker::Lorem.characters }
    fund_extra { Faker::Lorem.characters }
    amount { (100..10000).to_a.sample.to_d }
    txid { Faker::Lorem.characters(16) }
  end
end
