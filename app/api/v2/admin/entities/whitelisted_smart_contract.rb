# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class WhitelistedSmartContract < API::V2::Entities::Base
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Unique whitelisted smart contract identifier in database.'
            }
          )

          expose(
            :address,
            documentation: {
              type: String,
              desc: 'Whitelisted smart contract address.'
            }
          )

          expose(
            :description,
            documentation: {
              type: String,
              desc: 'Whitelisted smart contract description.'
            }
          )

          expose(
            :blockchain_key,
            documentation: {
              type: String,
              desc: 'Whitelisted smart contract blockchain key.'
            }
          )

          expose(
            :state,
            documentation: {
              type: String,
              desc: 'Whitelisted smart contract status (active/disabled).'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Whitelisted smart contract created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Whitelisted smart contract updated time in iso8601 format.'
            }
          )
        end
      end
    end
  end
end
