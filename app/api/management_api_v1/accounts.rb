# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Accounts < Grape::API
    desc 'Queries the account balance for the given UID and currency.' do
      @settings[:scope] = :read_accounts
      success ManagementAPIv1::Entities::Balance
    end

    params do
      requires :uid, type: String, desc: 'The shared user ID.'
      requires :currency, type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'The currency code.'
    end

    post '/accounts/balance' do
      member = Authentication.find_by!(provider: :barong, uid: params[:uid]).member
      account = member.get_account(params[:currency])
      present account, with: ManagementAPIv1::Entities::Balance
      status 200
    end
  end
end
