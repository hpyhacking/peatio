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
                 if: ->(operation) { operation.try(:member).try(:uid) },
                 documentation: {
                   type: String,
                   desc: 'The shared user ID.'
                 }) { |operation| operation.try(:member).try(:uid) }
         expose(:reference_type,
                documentation: {
                  type: String,
                  desc: 'The type of operations.'
                }) { |operation| operation.reference_type.downcase if operation.reference_type.present? }
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
