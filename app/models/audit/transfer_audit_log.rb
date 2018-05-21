# encoding: UTF-8
# frozen_string_literal: true

module Audit
  class TransferAuditLog < AuditLog
    class << self
      def audit!(transfer, operator = nil)
        create! \
          operator:     operator,
          auditable:    transfer,
          source_state: transfer.aasm_state_was,
          target_state: transfer.aasm_state
      end
    end
  end
end

# == Schema Information
# Schema version: 20180516105035
#
# Table name: audit_logs
#
#  id             :integer          not null, primary key
#  type           :string(30)       not null
#  operator_id    :integer
#  auditable_id   :integer          not null
#  auditable_type :string(30)       not null
#  source_state   :string(30)
#  target_state   :string(30)       not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_audit_logs_on_auditable_id_and_auditable_type  (auditable_id,auditable_type)
#  index_audit_logs_on_operator_id                      (operator_id)
#
