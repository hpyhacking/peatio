# frozen_string_literal: true

module Operations
  # {Liability} is a balance sheet operation
  class Liability < Operation
    belongs_to :member

    class << self
      def credit!(amount:, kind: :main, reference: nil,
                  member_id: nil, currency: nil)
        return if amount.zero?

        currency ||= reference.currency
        account_code = Operations::Chart.code_for(
          type:          operation_type,
          kind:          kind,
          currency_type: currency.type
        )
        new(
          credit:      amount,
          reference:   reference,
          currency_id: currency.id,
          code:        account_code,
          member_id:   member_id || reference.member_id
        ).tap(&:save!)
      end

      # TODO: Validate member balance before debit.
      def debit!(amount:, kind: :main, reference: nil,
                 member_id: nil, currency: nil)
        return if amount.zero?

        currency ||= reference.currency
        account_code = Operations::Chart.code_for(
          type:          operation_type,
          kind:          kind,
          currency_type: currency.type
        )
        create!(
          debit:       amount,
          reference:   reference,
          currency_id: currency.id,
          code:        account_code,
          member_id:   member_id || reference.member_id
        ).tap(&:save!)
      end

      def transfer!(amount:, from_kind:, to_kind:,
                    reference: nil, member_id: nil, currency: nil)
        params = {
          reference: reference,
          amount: amount,
          member_id: member_id,
          currency: currency
        }
        [debit!(params.merge(kind: from_kind)), credit!(params.merge(kind: to_kind))]
      end
    end
  end
end

# == Schema Information
# Schema version: 20181210162905
#
# Table name: liabilities
#
#  id             :integer          not null, primary key
#  code           :integer          not null
#  currency_id    :string(255)      not null
#  member_id      :integer          not null
#  reference_id   :integer
#  reference_type :string(255)
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
