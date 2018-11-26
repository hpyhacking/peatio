# frozen_string_literal: true

module Operations
  # {Liability} is a balance sheet operation
  class Liability < Operation
    class << self
      def credit!(reference:, amount:, kind:, member_id: nil, currency: nil)
        return if amount.zero?

        currency ||= reference.currency
        account_code = Operations::Chart.code_for(
          type:          operation_type,
          kind:          kind,
          currency_type: currency.type.to_sym
        )
        create!(
          credit:      amount,
          reference:   reference,
          currency_id: currency.id,
          code:        account_code,
          member_id:   member_id || reference.member_id
        )
      end

      # TODO: Validate member balance before debit.
      def debit!(reference:, amount:, kind:, member_id: nil, currency: nil)
        return if amount.zero?

        currency ||= reference.currency
        account_code = Operations::Chart.code_for(
          type:          operation_type,
          kind:          kind,
          currency_type: currency.type.to_sym
        )
        create!(
          debit:       amount,
          reference:   reference,
          currency_id: currency.id,
          code:        account_code,
          member_id:   member_id || reference.member_id
        )
      end

      def transfer!(reference:, amount:, from_kind:,
                    to_kind:, member_id: nil, currency: nil)
        debit!(reference: reference, amount: amount, kind: from_kind, member_id: member_id, currency: currency)
        credit!(reference: reference, amount: amount, kind: to_kind, member_id: member_id, currency: currency)
      end
    end
  end
end

# == Schema Information
# Schema version: 20181105120211
#
# Table name: liabilities
#
#  id             :integer          not null, primary key
#  code           :integer          not null
#  currency_id    :string(255)      not null
#  member_id      :integer          not null
#  reference_id   :integer          not null
#  reference_type :string(255)      not null
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
