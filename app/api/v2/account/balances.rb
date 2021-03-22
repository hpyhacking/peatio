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
          optional :account_type,
                   values: { value: ->(v) { (Array.wrap(v) - ::Account::TYPES).blank? }, message: 'account.type.doesnt_exist' },
                   desc: 'Accounts type.'
          optional :nonzero,
                   type: { value: Boolean, message: 'account.balances.invalid_nonzero' },
                   default: false,
                   desc: 'Filter non zero balances.'
          optional :search, type: JSON, default: {} do
            optional :currency_code,
                     as: :code,
                     type: String
            optional :currency_name,
                     as: :name,
                     type: String
          end
        end
        get '/balances' do
          user_authorize! :read, ::Operations::Account

          search_params = params[:search]
                          .slice(:code, :name)
                          .transform_keys { |k| "#{k}_cont" }
                          .merge(m: 'or')

          accounts = if params[:account_type].present?
                       current_user.accounts.where(type: params[:account_type]).visible.ransack(search_params).result
                     else
                       ::Currency.visible.ransack(search_params).result.each_with_object([]) do |c, result|
                         account = ::Account.find_by(currency: c, member: current_user, type: ::Account::DEFAULT_TYPE)
                         if account.present?
                           next if params[:nonzero].present? && account.amount.zero? && account.locked.zero?

                           result << account
                         elsif account.blank? && params[:nonzero].blank?
                           result << ::Account.new(currency: c, member: current_user, type: ::Account::DEFAULT_TYPE)
                         end
                       end
                     end

          present paginate(accounts.uniq),
                  with: Entities::Account, current_user: current_user
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
        get '/balances/:currency', requirements: { currency: /[\w\.\-]+/ } do
          user_authorize! :read, ::Operations::Account

          present current_user.accounts.visible.find_by!(currency_id: params[:currency]),
                  with: API::V2::Entities::Account
        end
      end
    end
  end
end
