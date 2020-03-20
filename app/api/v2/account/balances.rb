# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Account
      class Balances < Grape::API

        helpers ::API::V2::ParamHelpers

        # TODO: Add failures.
        # TODO: Move desc hash options to block once issues are resolved.
        # https://github.com/ruby-grape/grape/issues/1789
        # https://github.com/ruby-grape/grape-swagger/issues/705
        desc 'Get list of user accounts',
            is_array: true,
            success: API::V2::Entities::Account
        params do
          use :pagination
          optional :nonzero,
                   type: { value: Boolean, message: 'account.balances.invalid_nonzero' },
                   default: false,
                   desc: 'Filter non zero balances.'
          optional :search, type: JSON, default: {} do
            optional :currency_code,
                     type: String
            optional :currency_name,
                     type: String
          end
        end
        get '/balances' do
          search_params = params[:search]
                                .slice(:currency_code, :currency_name)
                                .transform_keys {|k| "#{k}_cont"}
                                .merge(m: 'or')

          search_params.merge!(balance_or_locked_gt: 0) if params[:nonzero]
          search = current_user.accounts.visible.ransack(search_params)

          present paginate(search.result),
                  with: Entities::Account
        end

        desc 'Get user account by currency' do
          success API::V2::Entities::Account
          # TODO: Add failures.
        end
        params do
          requires :currency,
                   type: String,
                   values: { value: -> { Currency.visible.pluck(:id) }, message: 'account.currency.doesnt_exist' },
                   desc: 'The currency code.'
        end

        get '/balances/:currency' do
          present current_user.accounts.visible.find_by!(currency_id: params[:currency]),
                  with: API::V2::Entities::Account
        end
      end
    end
  end
end
