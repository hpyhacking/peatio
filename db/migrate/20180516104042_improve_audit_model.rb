# encoding: UTF-8
# frozen_string_literal: true

class ImproveAuditModel < ActiveRecord::Migration
  def change
    change_column :audit_logs, :type, :string, limit: 30, null: false
    change_column :audit_logs, :operator_id, :integer, null: true
    change_column :audit_logs, :created_at, :datetime, after: :target_state, null: false
    change_column :audit_logs, :updated_at, :datetime, after: :created_at, null: false
    change_column :audit_logs, :auditable_type, :string, limit: 30, null: false
    change_column :audit_logs, :auditable_id, :integer, null: false
    change_column :audit_logs, :target_state, :string, null: false, limit: 30
    change_column :audit_logs, :source_state, :string, null: true, limit: 30
  end
end
