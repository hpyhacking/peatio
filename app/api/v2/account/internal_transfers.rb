# frozen_string_literal: true

module API
  module V2
    module Account
      class InternalTransfers < Grape::API
        namespace :internal_transfers do
          desc 'List your internal transfers as paginated collection.',
               is_array: true,
               success: API::V2::Entities::InternalTransfer
          params do
            optional :currency,
                     type: String,
                     values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist' },
                     desc: 'Currency code.'
            optional :state, type: String, desc: 'The state to filter by.'
            optional :sender
          end

          get do
            user_authorize! :read, ::InternalTransfer

            ransack_params = ::API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                                      .eq(:state)
                                                                      .translate(currency: :currency_id)
                                                                      .merge(g: [
                                                                               { sender_id_eq: current_user.id, receiver_id_eq: current_user.id, m: 'or' }
                                                                             ]).build
            search = InternalTransfer.ransack(ransack_params)
                                     .result
                                     .order('id desc')

            present paginate(search), with: API::V2::Entities::InternalTransfer, current_user: current_user
          end
          desc 'Creates internal transfer.'
          params do
            requires :currency,
                     type: String,
                     values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.currency.doesnt_exist' },
                     desc: 'The currency code.'
            requires :amount,
                     type: { value: BigDecimal, message: 'account.internal_transfer.non_decimal_amount' },
                     values: { value: ->(v) { v.try(:positive?) }, message: 'account.internal_transfer.non_positive_amount' },
                     desc: 'The amount to transfer.'
            requires :otp,
                     type: { value: Integer, message: 'account.internal_transfer.non_integer_otp' },
                     allow_blank: false,
                     desc: 'OTP to perform action'
            requires :username_or_uid,
                     type: String,
                     allow_blank: false,
                     desc: 'Receiver uid or username.'
          end
          post do
            receiver = Member.find_by_username_or_uid(params[:username_or_uid])

            error!({ errors: ['account.internal_transfer.receiver_not_found'] }, 422) if receiver.nil?
            currency = Currency.find(params[:currency])

            unless Vault::TOTP.validate?(current_user.uid, params[:otp])
              error!({ errors: ['account.internal_transfer.invalid_otp'] }, 422)
            end

            if current_user == receiver
              error!({ errors: ['account.internal_transfer.can_not_tranfer_to_yourself'] }, 422)
            end

            internal_transfer = ::InternalTransfer.new(
              currency: currency,
              sender: current_user,
              receiver: receiver,
              amount: params[:amount]
            )
            if internal_transfer.save
              present internal_transfer, with: API::V2::Entities::InternalTransfer
              status 201
            else
              body errors: internal_transfer.errors.full_messages
              status 422
            end

          rescue ::Account::AccountError => e
            report_api_error(e, request)
            error!({ errors: ['account.internal_transfer.insufficient_balance'] }, 422)
          rescue => e
            report_exception(e)
            error!({ errors: ['account.internal_transfer.create_error'] }, 422)
          end
        end
      end
    end
  end
end
