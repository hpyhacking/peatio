class RemoveAuditing < ActiveRecord::Migration[4.2]
  def change
    drop_table :audit_logs
    drop_table :versions
  end
end
