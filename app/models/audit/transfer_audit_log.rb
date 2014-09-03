module Audit
  class TransferAuditLog < AuditLog

    def self.audit!(transfer, operator = nil)
      create(operator_id: operator.try(:id), auditable: transfer,
             source_state: transfer.aasm_state_was, target_state: transfer.aasm_state)
    end

  end
end
