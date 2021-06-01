# frozen_string_literal: true

module Operations
  # {Liability} is a balance sheet operation
  class Liability < Operation
    belongs_to :member

    validates :member_id, presence: {
      if: ->(liability) { liability.account.scope == 'member' }
    }

    validates :member_id, absence: {
      if: ->(liability) { liability.account.scope != 'member' }
    }

    # Notify third party trading engine about member balance update.
    after_commit on: :create do
      AMQP::Queue.enqueue(:events_processor,
                        subject: :operation,
                        payload: as_json_for_events_processor)
    end

    def as_json_for_events_processor
      { code:           code,
        currency:       currency_id,
        member_id:      member_id,
        reference_id:   reference_id,
        reference_type: reference_type&.downcase,
        debit:          debit,
        credit:         credit }
    end
  end
end

# == Schema Information
# Schema version: 20210609094033
#
# Table name: liabilities
#
#  id             :bigint           not null, primary key
#  code           :integer          not null
#  currency_id    :string(255)      not null
#  member_id      :bigint
#  reference_type :string(255)
#  reference_id   :bigint
#  debit          :decimal(32, 16)  default(0.0), not null
#  credit         :decimal(32, 16)  default(0.0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_liabilities_on_currency_id                      (currency_id)
#  index_liabilities_on_member_id                        (member_id)
#  index_liabilities_on_reference_type_and_reference_id  (reference_type,reference_id)
#
