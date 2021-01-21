# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class InternalTransfer < Base

        expose(
          :currency_id,
          as: :currency,
          documentation: {
            type: String,
            desc: 'The currency code.'
          }
        )

        expose(
          :sender_username,
          documentation: {
            type: String,
            desc: 'The internal transfer sender.'
          }
        ) do |transfer|
            transfer.sender&.username
        end

        expose(
          :receiver_username,
          documentation: {
            type: String,
            desc: 'The internal transfer receiver.'
          }
        ) do |transfer|
            transfer.receiver&.username
        end

        expose(
          :sender_uid,
          documentation: {
            type: String,
            desc: 'The internal transfer sender.'
          }
        ) do |transfer|
            transfer.sender.uid
        end

        expose(
          :receiver_uid,
          documentation: {
            type: String,
            desc: 'The internal transfer receiver.'
          }
        ) do |transfer|
            transfer.receiver.uid
        end

        expose(
          :direction, ## call method from model
          documentation: {
            type: String,
            desc: 'The internal transfer direction (incoming or outcoming internal transfer).'
          }
        ) do |transfer, options|
          transfer.direction(options[:current_user])
        end

        expose(
          :amount,
          format_with: :decimal,
          documentation: {
            type: BigDecimal,
            desc: 'Internal transfer Amount.'
          }
        )

        expose(
          :state,
          as: :status,
          documentation: {
            type: String,
            desc: 'The internal transfer state.'
          }
        )

        expose(
          :created_at,
          :updated_at,
          format_with: :iso8601,
          documentation: {
            type: String,
            desc: 'The datetimes for the internal transfer.'
          }
        )
      end
    end
  end
end
