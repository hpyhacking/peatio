FactoryBot.define do
  factory :coin_withdraw_destination, class: 'WithdrawDestination::Coin' do
    label { 'My Bitcoin Wallet' }
    address { Faker::Bitcoin.address }
    currency { Currency.find_by!(code: :btc) }
    member { create(:member, :verified_identity) }

    factory :withdraw_destination
    factory :btc_withdraw_destination
  end

  factory :fiat_withdraw_destination, class: 'WithdrawDestination::Fiat' do
    label { 'My Bank Account' }
    currency { Currency.find_by!(code: :usd) }
    member { create(:member, :verified_identity) }
    bank_name { 'International Bank' }
    bank_branch_name { 'International Bank (branch #12345)' }
    bank_branch_address { 'Planet Earth' }
    bank_identifier_code { 'IB_12345_67890' }
    bank_account_number { 'BAN123456789' }
    bank_account_holder_name { 'John Doe' }

    factory :usd_withdraw_destination
  end
end
