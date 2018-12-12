# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      module Entities
        class Operation < Base
          expose :code,
                 documentation: {
                   type: String,
                   desc: 'The Account code which this operation related to.'
                 }
          expose :currency_id,
                 as: :currency,
                 documentation: {
                   type: String,
                   desc: 'Operation currency ID.'
                 }
          expose :credit,
                 if: ->(operation) { !operation.credit.zero? },
                 documentation: {
                   type: String,
                   desc: 'Operation credit amount.'
                 }
          expose :debit,
                 if: ->(operation) { !operation.debit.zero? },
                 documentation: {
                   type: String,
                   desc: 'Operation debit amount.'
                 }
          expose(:uid,
                 if: ->(operation) { operation.respond_to?(:member) },
                 documentation: {
                   type: String,
                   desc: 'The shared user ID.'
                 }) { |w| w.try(:member).try(:uid) }
          expose :created_at,
                 format_with: :iso8601,
                 documentation: {
                   type: String,
                   desc: 'The datetime when operation was created.'
                 }
        end
      end
    end
  end
end

#
# Table name: assets
#
#  id             :integer          not null, primary key
#  code           :integer          not null
#  currency_id    :string(255)      not null
#  reference_id   :integer
#  reference_type :string(255)
#  debit          :decimal(32, 16)  default(0.0), not null
#  credit         :decimal(32, 16)  default(0.0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_assets_on_currency_id                      (currency_id)
#  index_assets_on_reference_type_and_reference_id  (reference_type,reference_id)
#
