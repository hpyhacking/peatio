# encoding: UTF-8
# frozen_string_literal: true

class MigrateAllBankModelsToFiat < ActiveRecord::Migration
  def change
    execute %[ UPDATE deposits SET type = 'Deposits::Fiat' WHERE type = 'Deposits::Bank' ]
    execute %[ UPDATE withdraws SET type = 'Withdraws::Fiat' WHERE type = 'Withdraws::Bank' ]
  end
end
