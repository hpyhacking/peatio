# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :partial_tree do
    json { '{"partial_tree": {}}' }
    proof { create(:proof) }
    account { create_account }
  end
end
