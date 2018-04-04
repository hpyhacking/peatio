FactoryBot.define do
  factory :payment_transaction do
    txid { Faker::Internet.password(32, 64) }
    txout 0
    currency { Currency.find_by!(code: :btc) }
    amount { 10.to_d }
    payment_address
  end
end
