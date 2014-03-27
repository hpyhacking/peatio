FactoryGirl.define do
  factory :fund_source do
    extra 'bitcoin address'
    uid '1bitcoinaddress'
    channel_id '200'
    is_locked false

    member { create(:member) }

    trait :cny do
      extra 'cny bank'
      uid 'cnybankaddress'
      channel_id '400'
    end

    factory :cny_fund_source, traits: [:cny]
    factory :btc_fund_source
  end
end

