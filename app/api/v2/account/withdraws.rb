# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Account
      class Withdraws < Grape::API

        before { withdraws_must_be_permitted! }

        desc 'List your withdraws as paginated collection.',
          is_array: true,
          success: API::V2::Entities::Withdraw
        params do
          optional :currency,
                   type: String,
                   values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist'},
                   desc: 'Currency code.'
          optional :limit,
                   type: { value: Integer, message: 'account.withdraw.non_integer_limit' },
                   values: { value: 1..100, message: 'account.withdraw.invalid_limit' },
                   default: 100,
                   desc: "Number of withdraws per page (defaults to 100, maximum is 100)."
          optional :state,
                   values: { value: ->(v) { (Array.wrap(v) - Withdraw::STATES.map(&:to_s)).blank? }, message: 'account.withdraw.invalid_state' },
                   desc: 'Filter withdrawals by states.'
          optional :rid,
                   type: String,
                   allow_blank: false,
                   desc: 'Wallet address on the Blockchain.'
          optional :time_from,
                   allow_blank: { value: false, message: 'account.withdraw.empty_time_from' },
                   type: { value: Integer, message: 'account.withdraw.non_integer_time_from' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'
          optional :time_to,
                   type: { value: Integer, message: 'account.withdraw.non_integer_time_to' },
                   allow_blank: { value: false, message: 'account.withdraw.empty_time_to' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'
          optional :page,
                   type: { value: Integer, message: 'account.withdraw.non_integer_page' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'account.withdraw.non_positive_page'},
                   default: 1,
                   desc: 'Page number (defaults to 1).'
        end
        get '/withdraws' do
          user_authorize! :read, ::Withdraw

          currency = Currency.find(params[:currency]) if params[:currency].present?

          current_user.withdraws.order(id: :desc)
                      .tap { |q| q.where!(currency: currency) if currency }
                      .tap { |q| q.where!(aasm_state: params[:state]) if params[:state] }
                      .tap { |q| q.where!(rid: params[:rid]) if params[:rid] }
                      .tap { |q| q.where!('updated_at >= ?', Time.at(params[:time_from])) if params[:time_from].present? }
                      .tap { |q| q.where!('updated_at <= ?', Time.at(params[:time_to])) if params[:time_to].present? }
                      .tap { |q| present paginate(q), with: API::V2::Entities::Withdraw }
        end

        desc 'Returns withdrawal sums for last 4 hours and 1 month'
        get '/withdraws/sums' do
          user_authorize! :read, ::Withdraw

          sum_24_hours, sum_1_month = Withdraw.sanitize_execute_sum_queries(current_user.id)

          present({ last_24_hours: sum_24_hours, last_1_month: sum_1_month })
        end

        desc 'Creates new withdrawal to active beneficiary.'
        params do
          requires :otp,
                   type: { value: Integer, message: 'account.withdraw.non_integer_otp' },
                   allow_blank: false,
                   desc: 'OTP to perform action'
          requires :beneficiary_id,
                   type: { value: Integer, message: 'account.withdraw.non_integer_beneficiary_id' },
                   allow_blank: false,
                   desc: 'ID of Active Beneficiary belonging to user.'
          requires :currency,
                   type: String,
                   values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist'},
                   desc: 'The currency code.'
          requires :amount,
                   type: { value: BigDecimal, message: 'account.withdraw.non_decimal_amount' },
                   values: { value: ->(v) { v.try(:positive?) }, message: 'account.withdraw.non_positive_amount' },
                   desc: 'The amount to withdraw.'
          optional :note,
                   type: String,
                   values: { value: ->(v) { v.size <= 256 }, message: 'account.withdraw.too_long_note' },
                   desc: 'Optional user metadata to be applied to the transaction. Used to tag transactions with memorable comments.'
        end
        post '/withdraws' do
          user_authorize! :create, ::Withdraw

          withdraw_api_must_be_enabled!

          beneficiary = current_user
                          .beneficiaries
                          .available_to_member
                          .find_by(id: params[:beneficiary_id])

          if beneficiary.blank?
            error!({ errors: ['account.beneficiary.doesnt_exist'] }, 422)
          elsif !beneficiary.active?
            error!({ errors: ['account.beneficiary.invalid_state_for_withdrawal'] }, 422)
          end

          unless Vault::TOTP.validate?(current_user.uid, params[:otp])
            error!({ errors: ['account.withdraw.invalid_otp'] }, 422)
          end

          currency = Currency.find(params[:currency])

          unless currency.withdrawal_enabled?
            error!({ errors: ['account.currency.withdrawal_disabled'] }, 422)
          end

          # TODO: Delete subclasses from Deposit and Withdraw
          withdraw = "withdraws/#{currency.type}".camelize.constantize.new \
            beneficiary: beneficiary,
            sum:         params[:amount],
            member:      current_user,
            currency:    currency,
            note:        params[:note]
          withdraw.save!
          withdraw.with_lock { withdraw.accept! }
          present withdraw, with: API::V2::Entities::Withdraw

        rescue ::Account::AccountError => e
          report_api_error(e, request)
          error!({ errors: ['account.withdraw.insufficient_balance'] }, 422)
        rescue ActiveRecord::RecordInvalid => e
          report_api_error(e, request)
          # TODO: Check if there are other errors possible here.
          # For now single error which is not handled by params validations is
          # sum precision validation error (PrecisionValidator).
          error!({ errors: ['account.withdraw.invalid_amount'] }, 422)
        rescue => e
          report_exception(e)
          error!({ errors: ['account.withdraw.create_error'] }, 422)
        end
      end
    end
  end
end
