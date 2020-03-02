# frozen_string_literal: true

module API
  module V2
    module Public
      class Webhooks < Grape::API
        helpers ::API::V2::WebhooksHelpers

        desc 'Bitgo Transfer Webhook'
        params do
          requires :event,
                   type: String,
                   desc: 'Name of event can be deposit or withdraw',
                   values: { value: -> { %w[deposit withdraw] }, message: 'public.webhook.invalid_event' }
          requires :type,
                   type: String,
                   desc: 'Type of event.'
          given type: ->(val) { val == 'transfer' } do
            requires :hash,
                     type: String,
                     desc: 'Transfer txid.'
            requires :transfer,
                     type: String,
                     desc: 'Transfer id.'
            requires :coin,
                     type: String,
                     desc: 'Currency code.'
            requires :wallet,
                     type: String,
                     desc: 'Wallet id.'
          end
        end
        post '/webhooks/:event' do
          proces_webhook_event(params)
          status 200
        rescue StandardError => e
          Rails.logger.warn { "Cannot perform webhook: #{params}. Error: #{e}." }
          body errors: ["public.webhook.cannot_perfom_#{params['type']}"]
          status 422
        end
      end
    end
  end
end
