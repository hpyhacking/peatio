FactoryGirl.define do
  factory :payment_transaction do
    txid { Faker::Lorem.characters(16) }
    channel { create(:deposit_channel) }
    currency { 'btc' }
    amount { 10.to_d }
    payment_address { create(:payment_address) }
  end
end
