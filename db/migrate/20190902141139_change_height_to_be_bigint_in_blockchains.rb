class ChangeHeightToBeBigintInBlockchains < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      change_table :blockchains do |t|
        dir.up   { t.change :height, :bigint }
        dir.down { t.change :height, :integer }
      end
    end
  end
end
