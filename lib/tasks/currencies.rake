namespace :currencies do
  desc 'Adds missing currencies to database defined at config/seed/currencies.yml.'
  task seed: :environment do
    require 'yaml'
    Currency.transaction do
      YAML.load_file(Rails.root.join('config/seed/currencies.yml')).each do |hash|
        next if Currency.exists?(code: hash.fetch('code'))
        Currency.create!(hash)
      end
    end
  end
end
