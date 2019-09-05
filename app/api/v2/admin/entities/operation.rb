# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Operation < API::V2::Entities::Base
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Unique operation identifier in database.'
            }
          )

          expose(
            :code,
            documentation: {
              type: String,
              desc: 'The Account code which this operation related to.'
            }
          )

          expose(
            :currency_id,
            as: :currency,
            documentation: {
              type: String,
              desc: 'Operation currency ID.'
            }
          )

          expose(
            :credit,
            documentation: {
              type: String,
              desc: 'Operation credit amount.'
            }
          )

          expose(
            :debit,
            documentation: {
              type: String,
              desc: 'Operation debit amount.'
            }
          )

          expose(
            :uid,
            if: ->(operation) { operation.try(:member).try(:uid) },
            documentation: {
              type: String,
              desc: 'The shared user ID.'
            }) { |operation| operation.try(:member).try(:uid) }

          expose(
            :account_kind,
            documentation: {
              type: String,
              desc: 'Operation\'s account kind (locked or main).'
            }
          ) { |operation| operation.account.kind }

          expose(
            :reference_id,
            as: :rid,
            documentation: {
              type: String,
              desc: 'The id of operation reference.'
            }
          )

          expose(
            :reference_type,
            documentation: {
              type: String,
              desc: 'The type of operations.'
            }) { |operation| operation.reference_type.downcase if operation.reference_type.present? }

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetime when operation was created.'
            }
          )
        end
      end
    end
  end
end
