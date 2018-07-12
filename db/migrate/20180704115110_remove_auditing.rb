class RemoveAuditing < ActiveRecord::Migration
  def change
    drop_table :audit_logs
    drop_table :versions
  end
end
