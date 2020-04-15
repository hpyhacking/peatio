# frozen_string_literal: true

FactoryBot.define do
  factory :engine do
    name { Faker::Company.name }
    driver { 'peatio' }
    state { 'online' }
  end
end
