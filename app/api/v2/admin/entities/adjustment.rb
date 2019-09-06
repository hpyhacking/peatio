# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Adjustment < API::V2::Entities::Base
          expose(
            :id,
            documentation: {
              type: Integer,
              desc: 'Unique adjustment identifier in database.'
            }
          )

          expose(
            :reason,
            documentation: {
              type: String,
              desc: 'Adjustment reason.'
            }
          )

          expose(
            :description,
            documentation: {
              type: String,
              desc: 'Adjustment description.'
            }
          )

          expose(
            :category,
            documentation: {
              type: String,
              desc: 'Adjustment category'
            }
          )

          expose(
            :amount,
            documentation: {
              type: String,
              desc: 'Adjustment amount.'
            }
          )

          expose(
            :validator_uid,
            documentation: {
              type: Integer,
              desc: 'Unique adjustment validator identifier in database.'
            },
            if: ->(adjustment, _options) { adjustment.validator }
          ) do |adjustment, _options|
            adjustment.validator.uid
          end

          expose(
            :creator_uid,
            documentation: {
              type: Integer,
              desc: 'Unique adjustment creator identifier in database.'
            },
          ) do |adjustment, _options|
            adjustment.creator.uid
          end

          expose(
            :currency_id,
            as: :currency,
            documentation: {
              type: String,
              desc: 'Adjustment currency ID.'
            }
          )

          expose(
            :asset,
            using: API::V2::Admin::Entities::Operation,
            if: ->(adjustment, _options) { adjustment.fetch_asset }
          ) do |adjustment, _options|
            adjustment.fetch_asset
          end

          expose(
            :liability,
            using: API::V2::Admin::Entities::Operation,
            if: ->(adjustment, _options) { adjustment.fetch_liability }
          ) do |adjustment, _options|
            adjustment.fetch_liability
          end

          expose(
            :revenue,
            using: API::V2::Admin::Entities::Operation,
            if: ->(adjustment, _options) { adjustment.fetch_revenue }
          ) do |adjustment, _options|
            adjustment.fetch_revenue
          end

          expose(
            :expense,
            using: API::V2::Admin::Entities::Operation,
            if: ->(adjustment, _options) { adjustment.fetch_expense }
          ) do |adjustment, _options|
            adjustment.fetch_expense
          end

          expose(
            :state,
            documentation: {
              type: String,
              desc: 'Adjustment\'s state.'
            }
          )

          expose(
            :asset_account_code,
            documentation: {
              type: Integer,
              desc: 'Adjustment asset account code.'
            }
          )

          expose(
            :receiving_account_code,
            documentation: {
              type: String,
              desc: 'Adjustment receiving account code.'
            }
          ) do |adjustment, _options|
            ::Operations.split_account_number(account_number: adjustment.receiving_account_number)[:code]
          end

          expose(
            :receiving_member_uid,
            documentation: {
              type: String,
              desc: 'Adjustment receiving member uid.'
            },
            if: ->(adjustment, _options) { adjustment.fetch_liability.present? }
          ) do |adjustment, _options|
            ::Operations.split_account_number(account_number: adjustment.receiving_account_number)[:member_uid]
          end

          expose(
            :created_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetime when operation was created.'
            }
          )

          expose(
            :updated_at,
            format_with: :iso8601,
            documentation: {
              type: String,
              desc: 'The datetime when operation was updated.'
            }
          )
        end
      end
    end
  end
end
