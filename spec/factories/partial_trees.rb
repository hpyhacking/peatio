# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :partial_tree do
    json 'partial_tree: {}'
    proof_id 1
    account_id 1
  end
end
