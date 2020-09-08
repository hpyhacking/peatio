# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Deposit < API::V2::Entities::Deposit
          expose(
            :member_id,
            as: :member,
            documentation: {
              type: String,
              desc: 'The member id.'
            }
          )

          expose(
            :uid,
            documentation: {
              type: String,
              desc: 'Deposit member uid.'
            }
          )

          expose(
            :email,
            documentation: {
              type: String,
              desc: 'The deposit member email.'
            }
          ) { |d| d.member.email }

          expose(
            :address,
            documentation: {
              type: String,
              desc: 'Deposit blockchain address.'
            },
            if: ->(deposit) { deposit.currency.coin? }
          )

          expose(
            :txout,
            documentation: {
              type: Integer,
              desc: 'Deposit blockchain transaction output.'
            },
            if: ->(deposit) { deposit.currency.coin? }
          )

          expose(
            :block_number,
            documentation: {
              type: Integer,
              desc: 'Deposit blockchain block number.'
            },
            if: ->(deposit) { deposit.currency.coin? }
          )

          expose(
            :type,
            documentation: {
              type: String,
              desc: 'Deposit type (fiat or coin).'
            }
          ) { |d| d.currency.fiat? ? :fiat : :coin }

          expose(
            :tid,
            documentation: {
              type: String,
              desc: 'Deposit tid.'
            }
          )

          expose(
            :spread,
            documentation: {
              type: String,
              desc: 'Deposit collection spread.'
            },
            if: -> (deposit) { !deposit.spread.empty? }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetime when deposit was updated.'
            }
          )

          expose(
            :completed_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetime when deposit was completed.'
            },
            if: ->(deposit) { deposit.completed? }
          )
        end
      end
    end
  end
end
