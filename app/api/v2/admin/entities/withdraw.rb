# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Withdraw < API::V2::Entities::Withdraw
          expose(
            :member_id,
            as: :member,
            documentation: {
              type: String,
              desc: 'The member id.'
            }
          )

          expose(
            :beneficiary,
            using: API::V2::Admin::Entities::Beneficiary,
            if: ->(withdraw, options) do
              options[:with_beneficiary] && withdraw.beneficiary.present?
            end
          )

          expose(
            :uid,
            documentation: {
              type: String,
              desc: 'The withdrawal member uid.'
            }
          ) { |w| w.member.uid }

          expose(
            :email,
            documentation: {
              type: String,
              desc: 'The withdrawal member email.'
            }
          ) { |w| w.member.email }

          expose(
            :account,
            documentation: {
              type: String,
              desc: 'The account code.'
            }
          ) { |w| w.account.id }

          expose(
            :block_number,
            documentation: {
              type: Integer,
              desc: 'The withdrawal block_number.'
            },
            if: ->(w) { w.currency.coin? }
          )

          expose(
            :tid,
            documentation: {
              type: String,
              desc: 'Withdraw tid.'
            }
          )

          expose(
            :error,
            documentation: {
              type: String,
              desc: 'Withdraw error.'
            },
            unless: ->(w) { w.succeed? }
          )

          expose(
            :metadata,
            documentation: {
              type: String,
              desc: 'Optional metadata to be applied to the transaction.'
            }
          )
        end
      end
    end
  end
end
