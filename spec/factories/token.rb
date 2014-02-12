FactoryGirl.define do
  factory :reset_password do
    identity
    email { identity.email }
  end

  factory :reset_two_factor do
    identity
    email { identity.email }
  end
end
