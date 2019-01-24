# encoding: UTF-8
# frozen_string_literal: true

require_relative '../validations'

module API
  module V2
    module Account
      class Deposits < Grape::API
        helpers API::V2::NamedParams

        before { deposits_must_be_permitted! }

        desc 'Get your deposits history.',
          is_array: true,
          success: API::V2::Entities::Deposit

        params do
          optional :currency, type: String, values: -> { Currency.enabled.codes(bothcase: true) }, desc: -> { "Currency value contains #{Currency.enabled.codes(bothcase: true).join(',')}" }
          optional :state,    type: String, values: -> { Deposit::STATES.map(&:to_s) }
          optional :limit,    type: Integer, default: 100, range: 1..1000, desc: "Set result limit."
          optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
        end
        get "/deposits" do
          currency = Currency.find(params[:currency]) if params[:currency].present?

          current_user
            .deposits
            .order(id: :desc)
            .tap { |q| q.where!(currency: currency) if currency }
            .tap { |q| q.where!(aasm_state: params[:state]) if params[:state] }
            .page(params[:page])
            .per(params[:limit])
            .tap { |q| present q, with: API::V2::Entities::Deposit }
        end

        desc 'Get details of specific deposit.' do
          success API::V2::Entities::Deposit
        end
        params do
          requires :txid
        end
        get "/deposits/:txid" do
          deposit = current_user.deposits.find_by(txid: params[:txid])
          raise DepositByTxidNotFoundError, params[:txid] unless deposit

          present deposit, with: API::V2::Entities::Deposit
        end

        desc 'Returns deposit address for account you want to deposit to by currency. ' \
          'The address may be blank because address generation process is still in progress. ' \
          'If this case you should try again later.',
          success: API::V2::Entities::Deposit
        params do
          requires :currency, type: String, values: -> { Currency.coins.enabled.codes(bothcase: true) }, desc: 'The account you want to deposit to.'
          given :currency do
            optional :address_format, type: String, values: -> { %w[legacy cash] }, validate_currency_address_format: true, desc: 'Address format legacy/cash'
          end
        end
        get '/deposit_address/:currency' do
          current_user.ac(params[:currency]).payment_address.yield_self do |pa|
            { currency: params[:currency], address: params[:address_format] ? pa.format_address(params[:address_format]) : pa.address }
          end
        end
      end
    end
  end
end
