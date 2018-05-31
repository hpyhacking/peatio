# encoding: UTF-8
# frozen_string_literal: true

namespace :currencies do
  desc 'Adds missing currencies to database defined at config/seed/currencies.yml.'
  task seed: :environment do
    require 'yaml'
    Currency.transaction do
      YAML.load_file(Rails.root.join('config/seed/currencies.yml')).each do |hash|
        next if Currency.exists?(id: hash.fetch('id'))
        Currency.create!(hash)
      end
    end
  end
end
