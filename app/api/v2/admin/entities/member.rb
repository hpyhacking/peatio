# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Member < API::V2::Entities::Member
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Unique member identifier in database.'
            }
          )

          expose(
            :level,
            documentation: {
              type: Integer,
              desc: 'Member\'s level.'
            }
          )

          expose(
            :role,
            documentation: {
              type: String,
              desc: 'Member\'s role.'
            }
          )

          expose(
            :state,
            documentation: {
              type: String,
              desc: 'Member\'s state.'
            }
          )

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Member created time in iso8601 format.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'Member updated time in iso8601 format.'
            }
          )

          expose(
            :beneficiaries,
            using: API::V2::Admin::Entities::Beneficiary,
            documentation: {
              type: 'API::V2::Admin::Entities::Beneficiary',
              is_array: true,
              desc: 'Member Beneficiary.'
            }
          ) do |m|
            m.beneficiaries
          end

          expose(
            :accounts,
            using: API::V2::Entities::Account,
            documentation: {
              type: 'API::V2::Entities::Account',
              is_array: true,
              desc: 'Member accounts.'
            }
          ) do |m|
            m.accounts.includes(:currency)
          end

          expose(
            :payment_addresses,
            as: :deposit_addresses,
            using: API::V2::Entities::PaymentAddress,
            documentation: {
              type: 'API::V2::Entities::PaymentAddress',
              is_array: true,
              desc: 'Member deposits addresses'
            }
          )
        end
      end
    end
  end
end
