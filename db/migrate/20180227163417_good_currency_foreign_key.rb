# encoding: UTF-8
# frozen_string_literal: true

class GoodCurrencyForeignKey < ActiveRecord::Migration
  def change
    %i[ account_versions accounts deposits fund_sources payment_addresses payment_transactions proofs withdraws ].each do |t|
      remove_index t, :currency if index_exists?(t, :currency)
      rename_column t, :currency, :currency_id
      add_index t, :currency_id
    end
  end
end
