# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class BlockchainCurrency < API::V2::Entities::BlockchainCurrency
          expose(
            :options,
            documentation: {
              type: JSON,
              desc: 'Blockchain currency options.'
            },
            if: -> (blockchain_currency){ blockchain_currency.currency.coin? }
          )

          expose(
            :min_collection_amount,
            documentation: {
              type: BigDecimal,
              desc: 'Minimal collection amount.'
            }
          )

          expose(
            :auto_update_fees_enabled,
            documentation: {
              desc: 'Blockchain auto adjust fees',
            }
          )

          expose(
            :subunits,
            documentation: {
              type: Integer,
              desc: 'Fraction of the basic monetary unit.'
            }
          ) { |blockchain_currency| blockchain_currency.subunits }

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Blockchain currency created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Blockchain currency updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
