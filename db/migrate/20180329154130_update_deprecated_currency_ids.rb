# encoding: UTF-8
# frozen_string_literal: true

class UpdateDeprecatedCurrencyIds < ActiveRecord::Migration
  def change
    # Migrate deprecated market codes to new.
    if File.file?('config/markets.old.yml')
      (YAML.load_file('config/markets.old.yml') || []).each do |market|
        execute %{UPDATE orders SET market_id = '#{market.fetch('id')}' WHERE market_id = '#{market.fetch('code')}'}
        execute %{UPDATE trades SET market_id = '#{market.fetch('id')}' WHERE market_id = '#{market.fetch('code')}'}
      end
    end
  end
end
