# frozen_string_literal: true

FactoryBot.define do
  factory :engine do
    name { Faker::Company.unique.bs.strip.downcase }
    driver { 'peatio' }
    state { 'online' }
  end
end
