module Audit
  class AuditLog < ActiveRecord::Base
    belongs_to :operator, class_name: 'Member', foreign_key: 'operator_id'
    belongs_to :auditable, polymorphic: true
  end
end
