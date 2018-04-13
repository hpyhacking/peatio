FactoryBot.define do
  factory :deposit do
    member { create(:member, :verified_identity) }
    amount { Kernel.rand(100..10_000).to_d }

    factory :deposit_btc, class: 'Deposits::Coin' do
      currency { Currency.find_by!(code: :btc) }
      address { Faker::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end

    factory :deposit_usd, class: 'Deposits::Fiat' do
      currency { Currency.find_by!(code: :usd) }
    end
  end
end
