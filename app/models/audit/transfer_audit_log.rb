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

class TransferAuditLog < AuditLog

  def self.audit!(transfer, operator = nil)
    TransferAuditLog.create(operator_id: operator.try(:id), auditable: transfer,
                            source_state: transfer.aasm_state_was, target_state: transfer.aasm_state)
  end

end
