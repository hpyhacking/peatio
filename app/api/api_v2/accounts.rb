# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Accounts < Grape::API
    helpers ::APIv2::NamedParams
    before { authenticate! }

    # TODO: Add failures.
    # TODO: Move desc hash options to block once issues are resolved.
    # https://github.com/ruby-grape/grape/issues/1789
    # https://github.com/ruby-grape/grape-swagger/issues/705
    desc 'Get list of user accounts',
         is_array: true,
         success: Entities::Account
    get '/accounts' do
      present current_user.accounts, with: Entities::Account
    end

    desc 'Get user account by currency' do
      success Entities::Account
      # TODO: Add failures.
    end
    params do
      use :currency
    end
    get '/accounts/:currency' do
      present current_user.accounts.find_by!(params[:currency]),
              with: Entities::Account
    end
  end
end
