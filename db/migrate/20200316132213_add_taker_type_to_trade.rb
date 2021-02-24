class AddTakerTypeToTrade < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        add_column :trades, :taker_type, :string, limit: 20, after: :taker_id, null: false, default: ''
      end

      dir.down do
        remove_column :trades, :taker_type
      end
    end
  end
end
