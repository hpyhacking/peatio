FactoryBot.define do
  factory :deposit do
    member { create(:member, :verified_identity) }
    amount { (100..10_000).to_a.sample.to_d }
    txid { Faker::Lorem.characters(16) }

    factory :deposit_btc, class: 'Deposits::Coin' do
      currency { Currency.find_by!(code: :btc) }
      account { member.get_account(:btc) }
      payment_transaction { create(:payment_transaction) }
    end

    factory :deposit_usd, class: 'Deposits::Fiat' do
      currency { Currency.find_by!(code: :usd) }
      account { member.get_account(:usd) }
    end
  end
end
