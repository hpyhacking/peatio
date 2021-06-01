# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Currency < Base
        expose(
          :id,
          documentation: {
            desc: 'Currency code.',
            type: String,
            values: -> { ::Currency.visible.codes },
            example: -> { ::Currency.visible.first.id }
          }
        )

        expose(
          :name,
          documentation: {
              type: String,
              desc: 'Currency name',
              example: -> { ::Currency.visible.first.name }
          },
          if: -> (currency){ currency.name.present? }
        )

        expose(
          :description,
          documentation: {
            type: String,
            desc: 'Currency description',
            example: -> { ::Currency.visible.first.description }
          }
        )

        expose(
          :homepage,
          documentation: {
            type: String,
            desc: 'Currency homepage',
            example: -> { ::Currency.visible.first.homepage }
          }
        )

        expose(
          :parent_id,
          documentation: {
            type: String,
            desc: 'Currency parent id',
            example: -> { ::Currency.visible.first.parent_id }
          },
          if: -> (currency){ currency.parent_id.present? }
        )

        expose(
          :price,
          documentation: {
            desc: 'Currency current price'
          }
        )

        expose(
          :type,
          documentation: {
            type: String,
            values: -> { ::Currency.types },
            desc: 'Currency type',
            example: -> { ::Currency.visible.first.type }
          }
        )

        expose(
          :precision,
          documentation: {
            desc: 'Currency precision',
            example: -> { ::Currency.visible.first.precision }
          }
        )

        expose(
          :position,
          documentation: {
            desc: 'Position used for defining currencies order',
            example: -> { ::Currency.visible.first.position }
          }
        )

        expose(
          :icon_url,
          documentation: {
            desc: 'Currency icon',
            example: 'https://upload.wikimedia.org/wikipedia/commons/0/05/Ethereum_logo_2014.svg'
          },
          if: -> (currency){ currency.icon_url.present? }
        )

        expose(
          :blockchain_currencies,
          using: API::V2::Entities::BlockchainCurrency,
          documentation: {
            type: 'API::V2::Entities::BlockchainCurrency',
            is_array: true,
            desc: 'Currency networks.'
          },
        ) do |c|
          c.blockchain_currencies
        end
      end
    end
  end
end
