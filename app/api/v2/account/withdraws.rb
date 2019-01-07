# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Account
      class Withdraws < Grape::API
        helpers API::V2::NamedParams

        before { withdraws_must_be_permitted! }

        desc 'List your withdraws as paginated collection.',
          is_array: true,
          success: API::V2::Entities::Withdraw
        params do
          optional :currency, type: String,  values: -> { Currency.enabled.codes(bothcase: true) }, desc: -> { "Any supported currencies: #{Currency.enabled.codes(bothcase: true).join(',')}." }
          optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'Page number (defaults to 1).'
          optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'Number of withdraws per page (defaults to 100, maximum is 1000).'
        end
        get '/withdraws' do
          currency = Currency.find(params[:currency]) if params[:currency].present?

          current_user
            .withdraws
            .order(id: :desc)
            .tap { |q| q.where!(currency: currency) if currency }
            .page(params[:page])
            .per(params[:limit])
            .tap { |q| present q, with: API::V2::Entities::Withdraw }
        end

        desc 'Creates new crypto withdrawal.'
        params do
          requires :otp,
                   type: Integer,
                   desc: 'OTP to perform action',
                   allow_blank: false
          requires :rid,
                   type: String,
                   desc: 'Wallet address on the Blockchain.',
                   allow_blank: false
          requires :currency,
                   type: String,
                   values: -> { Currency.coins.codes(bothcase: true) },
                   desc: 'The currency code.'
          requires :amount,
                   type: BigDecimal,
                   values: { value: ->(v) { v.to_d.positive? }, message: 'must be positive' },
                   desc: 'The amount to withdraw.'
        end
        post '/withdraws' do
          withdraw_api_must_be_enabled!

          unless Vault::TOTP.validate?(current_user.uid, params[:otp])
            raise Error.new(text: 'OTP code is invalid', status: 422)
          end

          currency = Currency.find(params[:currency])
          withdraw = ::Withdraws::Coin.new \
            sum:            params[:amount],
            member:         current_user,
            currency:       currency,
            rid:            params[:rid]

          if withdraw.save
            withdraw.with_lock { withdraw.submit! }
            present withdraw, with: API::V2::Entities::Withdraw
          else
            body errors: withdraw.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
