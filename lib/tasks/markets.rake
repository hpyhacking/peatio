namespace :markets do
  desc 'Adds missing markets to database defined at config/seed/markets.yml.'
  task seed: :environment do
    Market.transaction do
      YAML.load_file(Rails.root.join('config/seed/markets.yml')).each do |hash|
        next if Market.exists?(id: hash.fetch('id'))
        Market.create!(hash)
      end
    end
  end
end
