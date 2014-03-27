FactoryGirl.define do
  factory :deposit do
    member { create(:member) }
    account { member.get_account(currency) }
    channel_id { create(:deposit_channel).id }
    currency { 'btc' }
    fund_source_uid { Faker::Lorem.characters }
    fund_source_extra { Faker::Lorem.characters }
    amount { (100..10000).to_a.sample.to_d }
    txid { Faker::Lorem.characters(16) }
  end
end
