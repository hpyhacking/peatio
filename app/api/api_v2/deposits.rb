# encoding: UTF-8
# frozen_string_literal: true

require_relative 'validations'

module APIv2
  class Deposits < Grape::API
    helpers ::APIv2::NamedParams

    before { authenticate! }
    before { deposits_must_be_permitted! }

    desc 'Get your deposits history.'
    params do
      optional :currency, type: String, values: -> { Currency.enabled.codes(bothcase: true) }, desc: -> { "Currency value contains #{Currency.enabled.codes(bothcase: true).join(',')}" }
      optional :limit, type: Integer, range: 1..100, default: 3, desc: "Set result limit."
      optional :state, type: String, values: -> { Deposit::STATES.map(&:to_s) }
    end
    get "/deposits" do
      deposits = current_user.deposits.includes(:currency).limit(params[:limit]).recent
      deposits = deposits.with_currency(params[:currency]) if params[:currency]
      deposits = deposits.where(aasm_state: params[:state]) if params[:state].present?
      present deposits, with: APIv2::Entities::Deposit
    end

    desc 'Get details of specific deposit.'
    params do
      requires :txid
    end
    get "/deposit" do
      deposit = current_user.deposits.find_by(txid: params[:txid])
      raise DepositByTxidNotFoundError, params[:txid] unless deposit

      present deposit, with: APIv2::Entities::Deposit
    end

    desc 'Returns deposit address for account you want to deposit to. ' \
         'The address may be blank because address generation process is still in progress. ' \
         'If this case you should try again later.'
    params do
      requires :currency, type: String, values: -> { Currency.coins.enabled.codes(bothcase: true) }, desc: 'The account you want to deposit to.'
      given :currency do
        optional :address_format, type: String, values: -> { %w[legacy cash] }, validate_currency_address_format: true, desc: 'Address format legacy/cash'
      end
    end
    get '/deposit_address' do
      current_user.ac(params[:currency]).payment_address.yield_self do |pa|
        { currency: params[:currency], address: params[:address_format] ? pa.format_address(params[:address_format]) : pa.address }
      end
    end

    desc 'Returns new deposit address for account you want to deposit to. ' \
         'The address may be blank because address generation process is still in progress. ' \
         'If this case you should try again later. '
    params do
      requires :currency, type: String, values: -> { Currency.coins.enabled.codes(bothcase: true) }, desc: 'The account you want to deposit to.'
    end
    post '/deposit_address' do
      current_user.ac(params[:currency]).payment_address!.yield_self do |pa|
        { currency: params[:currency], address: pa.address }
      end
    end
  end
end
