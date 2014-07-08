# == Schema Information
#
# Table name: audit_logs
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  operator_id    :integer
#  created_at     :datetime
#  updated_at     :datetime
#  auditable_id   :integer
#  auditable_type :string(255)
#  source_state   :string(255)
#  target_state   :string(255)
#

class AuditLog < ActiveRecord::Base
  belongs_to :operator, class_name: 'Member', foreign_key: 'operator_id'
  belongs_to :auditable, polymorphic: true
end
