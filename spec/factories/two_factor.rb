FactoryGirl.define do
  factory :two_factor do
    trait :activated do
      activated true
    end
  end

  factory :two_factor_app,
    class: TwoFactor::App,
    parent: :two_factor do
  end

  factory :two_factor_sms,
    class: TwoFactor::Sms,
    parent: :two_factor do
  end
end

