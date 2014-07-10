class CreateAuditLogs < ActiveRecord::Migration
  def change
    create_table :audit_logs do |t|
      # Common Properties
      t.string :type
      t.integer :operator_id
      t.timestamps
      t.integer :auditable_id
      t.string :auditable_type

      # For Deposit and Withdraw
      t.string :source_state
      t.string :target_state
    end

    add_index :audit_logs, :operator_id
    add_index :audit_logs, [:auditable_id, :auditable_type]
  end
end
