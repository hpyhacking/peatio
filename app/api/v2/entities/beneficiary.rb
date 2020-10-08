# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Beneficiary < Base
        expose(
          :id,
          documentation: {
            desc: 'Beneficiary Identifier in Database',
            type: Integer
          }
        )

        expose(
          :currency_id,
          as: :currency,
          documentation: {
            desc: 'Beneficiary currency code.',
            type: String
          }
        )

        expose(
          :uid,
          documentation: {
            desc: 'Beneficiary owner',
            type: String
          }
        ) { |b| b.member.uid }

        expose(
          :name,
          documentation: {
            desc: 'Human rememberable name which refer beneficiary.',
            type: String
          }
        )

        expose(
          :description,
          documentation: {
            desc: 'Human rememberable description of beneficiary.',
            type: String
          }
        )

        expose(
          :data,
          documentation: {
            desc: 'Bank Account details for fiat Beneficiary in JSON format.'\
                  'For crypto it\'s blockchain address.',
            type: JSON
          }
        ) do |beneficiary|
          beneficiary.currency.fiat? ? beneficiary.masked_data : beneficiary.data
        end

        expose(
          :state,
          documentation: {
            desc: 'Defines either beneficiary active - user can use it to withdraw money'\
                  'or pending - requires beneficiary activation with pin.',
            type: String
          }
        )

        expose(
            :sent_at,
            format_with: :iso8601,
            documentation: {
                desc: 'Time when last pin was sent',
                type: String
            }
        )
      end
    end
  end
end
