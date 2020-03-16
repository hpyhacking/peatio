class AddTakerTypeToTrade < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        add_column :trades, :taker_type, :string, limit: 20, after: :taker_id, null: false
        Trade.find_each do |t|
          t.update_attribute(:taker_type, t.taker_order.side)
        end
      end

      dir.down do
        remove_column :trades, :taker_type
      end
    end
  end
end
