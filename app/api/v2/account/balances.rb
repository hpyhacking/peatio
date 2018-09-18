# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Account
      class Balances < Grape::API
        helpers API::V2::NamedParams
        before { authenticate! }

        # TODO: Add specs for this API
        # TODO: Add failures.
        # TODO: Move desc hash options to block once issues are resolved.
        # https://github.com/ruby-grape/grape/issues/1789
        # https://github.com/ruby-grape/grape-swagger/issues/705
        desc 'Get list of user accounts',
            is_array: true,
            success: API::V2::Entities::Account
        get '/balances' do
          present current_user.accounts.enabled, with: Entities::Account
        end

        desc 'Get user account by currency' do
          success API::V2::Entities::Account
          # TODO: Add failures.
        end
        params do
          use :currency
        end
        get '/balances/:currency' do
          present current_user.accounts.enabled.find_by!(currency_id: params[:currency]),
                  with: API::V2::Entities::Account
        end
      end
    end
  end
end
