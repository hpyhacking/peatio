FactoryGirl.define do
  factory :two_factor do
    activated true
    after(:build) do |two_factor| two_factor.refresh end
  end
end

