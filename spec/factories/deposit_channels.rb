FactoryGirl.define do
  factory :deposit_channel do
    id {(1..100).to_a.sample}

    after(:build) do |channel|
      channel.stubs(:key).returns('default')
      channel.class.stubs(:get).returns(channel)
      channel.class.stubs(:find_by_id).returns(channel)
    end
  end
end
