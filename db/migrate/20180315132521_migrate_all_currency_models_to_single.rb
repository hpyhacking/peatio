# encoding: UTF-8
# frozen_string_literal: true

class MigrateAllCurrencyModelsToSingle < ActiveRecord::Migration[4.2]
  def change
    execute %[ UPDATE deposits SET type = 'Deposits::Coin' WHERE type <> 'Deposits::Bank' ]
    execute %[ UPDATE withdraws SET type = 'Withdraws::Coin' WHERE type <> 'Withdraws::Bank' ]
  end
end
