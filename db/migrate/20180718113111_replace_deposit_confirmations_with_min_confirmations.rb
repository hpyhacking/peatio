class ReplaceDepositConfirmationsWithMinConfirmations < ActiveRecord::Migration
  class Currency < ActiveRecord::Base
    serialize :options, JSON
    self.table_name = 'currencies'
    self.inheritance_column = :disabled
  end

  def change
    currencies = YAML.load_file(Rails.root.join('config/seed/currencies.yml'))
    Currency.where(type: :coin).find_each do |c|
      currency_options = currencies.find { |el| el['id'] == c.id }['options']
      min_confirmations = currency_options['min_confirmations'] || c.options['deposit_confirmations'].to_i
      c.options.except!('deposit_confirmations').merge!(min_confirmations: min_confirmations)
      c.save!
    end
  end
end
