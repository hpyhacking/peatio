class MigrateAllCurrencyModelsToSingle < ActiveRecord::Migration
  def change
    execute %[ UPDATE deposits SET type = 'Deposits::Coin' WHERE type <> 'Deposits::Bank' ]
    execute %[ UPDATE withdraws SET type = 'Withdraws::Coin' WHERE type <> 'Withdraws::Bank' ]
  end
end
