class AddSpeedToBlockchains < ActiveRecord::Migration[5.2]
  def change
    add_column :blockchains, :step, :integer, default: 6, null: false, after: :height
  end
end
