# encoding: UTF-8
# frozen_string_literal: true

class MigrateDepositChannelsToCurrency < ActiveRecord::Migration
  def change
    if defined?(Currency) && File.file?('config/deposit_channels.old.yml')
      (YAML.load_file('config/deposit_channels.old.yml') || []).each do |channel|
        next unless channel.key?('min_confirm')
        Currency.find(channel.fetch('currency')).tap do |ccy|
          ccy.update_columns(options: ccy.options.reverse_merge(deposit_confirmations: channel['min_confirm']))
        end
      end
    end
  end
end
