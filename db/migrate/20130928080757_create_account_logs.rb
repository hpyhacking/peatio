class CreateAccountLogs < ActiveRecord::Migration
  def change
    create_table :account_logs do |t|
      t.integer :member_id
      t.integer :account_id
      t.integer :reason
      t.decimal :balance, :precision => 32, :scale => 16
      t.decimal :locked, :precision => 32, :scale => 16
      t.decimal :amount, :precision => 32, :scale => 16
      t.references :modifiable, polymorphic: true
      t.text :detail
      t.timestamps

      t.index [:member_id, :reason]
      t.index [:account_id, :reason]
      t.index [:modifiable_id, :modifiable_type]
    end
  end
end
