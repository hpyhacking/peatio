# encoding: UTF-8
# frozen_string_literal: true

require_relative '../validations'

module API
  module V2
    module Account
      class Deposits < Grape::API

        before { deposits_must_be_permitted! }

        desc 'Get your deposits history.',
          is_array: true,
          success: API::V2::Entities::Deposit

        params do
          optional :currency,
                   type: String,
                   values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist' },
                   desc: 'Currency code'
          optional :state,
                   type: String,
                   values: { value: -> { Deposit::STATES.map(&:to_s) }, message: 'account.deposit.invalid_state' }
          optional :limit,
                   type: { value: Integer, message: 'account.deposit.non_integer_limit' },
                   values: { value: 1..100, message: 'account.deposit.invalid_limit' },
                   default: 100,
                   desc: "Number of deposits per page (defaults to 100, maximum is 100)."
          optional :page,
                   type: { value: Integer, message: 'account.deposit.non_integer_page' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'account.deposit.non_positive_page'},
                   default: 1,
                   desc: 'Page number (defaults to 1).'
        end
        get "/deposits" do
          currency = Currency.find(params[:currency]) if params[:currency].present?

          current_user.deposits.order(id: :desc)
                      .tap { |q| q.where!(currency: currency) if currency }
                      .tap { |q| q.where!(aasm_state: params[:state]) if params[:state] }
                      .tap { |q| present paginate(q), with: API::V2::Entities::Deposit }
        end

        desc 'Get details of specific deposit.' do
          success API::V2::Entities::Deposit
        end
        params do
          requires :txid,
                   type: String,
                   allow_blank: false,
                   desc: "Deposit transaction id"
        end
        get "/deposits/:txid" do
          deposit = current_user.deposits.find_by!(txid: params[:txid])
          present deposit, with: API::V2::Entities::Deposit
        end

        desc 'Returns deposit address for account you want to deposit to by currency. ' \
          'The address may be blank because address generation process is still in progress. ' \
          'If this case you should try again later.',
          success: API::V2::Entities::Deposit
        params do
          requires :currency,
                   type: String,
                   values: { value: -> { Currency.coins.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist'},
                   desc: 'The account you want to deposit to.'
          given :currency do
            optional :address_format,
                     type: String,
                     values: { value: -> { %w[legacy cash] }, message: 'account.deposit_address.invalid_address_format' },
                     validate_currency_address_format: { value: true, prefix: 'account.deposit_address' },
                     desc: 'Address format legacy/cash'
          end
        end
        get '/deposit_address/:currency' do
          currency = Currency.find(params[:currency])

          unless currency.deposit_enabled?
            error!({ errors: ['account.currency.deposit_disabled'] }, 422)
          end

          current_user.ac(currency).payment_address.yield_self do |pa|
            { currency: params[:currency], address: params[:address_format] ? pa.format_address(params[:address_format]) : pa.address }
          end
        end
      end
    end
  end
end
