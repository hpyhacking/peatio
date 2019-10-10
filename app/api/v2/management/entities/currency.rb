# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      module Entities
        class Currency < ::API::V2::Entities::Currency

          expose(
            :code,
            documentation: {
              desc: 'Unique currency code.',
              type: String
            }
          )

          expose(
            :min_collection_amount,
            documentation: {
              desc: 'Minimal deposit amount that will be collected',
              example: -> { ::Currency.visible.first.min_collection_amount }
            }
          )

          expose(
            :visible,
            documentation: {
              type: String,
              desc: 'Currency display possibility status (true/false).'
            }
          )

          expose(
            :subunits,
            documentation: {
              type: Integer,
              desc: 'Fraction of the basic monetary unit.'
            }
          ) { |currency| currency.subunits }

          expose(
            :options,
            documentation: {
              type: JSON,
              desc: 'Currency options.'
            },
            if: -> (currency){ currency.coin? }
          )

          expose(
            :position,
            documentation: {
              type: Integer,
              desc: 'Currency position.'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Currency created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Currency updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
