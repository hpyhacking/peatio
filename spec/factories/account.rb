FactoryBot.define do
  factory :account do
    locked { '0.0'.to_d }
    balance { '100.0'.to_d }
    currency { Currency.find_by!(code: :usd) }

    factory :account_usd do
      currency { Currency.find_by!(code: :usd) }
    end
    
    factory :account_btc do
      currency { Currency.find_by!(code: :btc) }
    end

    factory :account_pts do
      currency { Currency.find_by!(code: :pts) }
    end
  end
end
