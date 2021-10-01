# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Deposits < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Get all deposits, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Deposit
        params do
          optional :state,
                   values: { value: -> { ::Deposit.aasm.states.map(&:name).map(&:to_s) }, message: 'admin.deposit.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:state][:desc] }
          optional :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:id][:desc] }
          optional :txid,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:txid][:desc] }
          optional :address,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:address][:desc] }
          optional :tid,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:tid][:desc] }
          optional :email,
                  desc: -> { API::V2::Admin::Entities::Deposit.documentation[:email][:desc] }
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.beneficiary.blockchain_key_doesnt_exist' },
                   desc: 'Blockchain key of the requested deposit'
          use :uid
          use :currency
          use :currency_type
          use :date_picker
          use :pagination
          use :ordering
        end
        get '/deposits' do
          admin_authorize! :read, ::Deposit

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:id, :txid, :tid, :address, :blockchain_key)
                             .translate(state: :aasm_state, uid: :member_uid, currency: :currency_id, email: :member_email)
                             .with_daterange
                             .merge(type_eq: params[:type].present? ? "Deposits::#{params[:type].capitalize}" : nil)
                             .build

          search = Deposit.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::Deposit
        end

        desc 'Take an action on the deposit.',
          success: API::V2::Admin::Entities::Deposit
        params do
          requires :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:id][:desc] }
          requires :action,
                   type: String,
                   values: { value: -> { ::Deposit.aasm.events.map(&:name).map(&:to_s) }, message: 'admin.deposit.invalid_action' },
                   desc: "Valid actions are #{::Deposit.aasm.events.map(&:name)}."
        end
        post '/deposits/actions' do
          admin_authorize! :update, ::Deposit

          deposit = Deposit.find(params[:id])

          if deposit.public_send("may_#{params[:action]}?")
            deposit.public_send("#{params[:action]}!")
            present deposit, with: API::V2::Admin::Entities::Deposit
          else
            body errors: ["admin.depodit.cannot_#{params[:action]}"]
            status 422
          end
        end

        desc 'Creates new fiat deposit .',
          success: API::V2::Admin::Entities::Deposit
        params do
          requires :uid,
                   values: { value: -> (v) { Member.exists?(uid: v) }, message: 'admin.deposit.user_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:uid][:desc] }
          requires :currency,
                   values: { value: -> { Currency.fiats.codes(bothcase: true) }, message: 'admin.deposit.currency_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:currency][:desc] }
          requires :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.beneficiary.blockchain_key_doesnt_exist' },
                   desc: 'Blockchain key of the requested beneficiary'
          requires :amount,
                   type: { value: BigDecimal, message: 'admin.deposit.non_decimal_amount' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:amount][:desc] }
          optional :tid,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:tid][:desc] }
        end
        post '/deposits/new' do
          admin_authorize! :create, ::Deposits::Fiat

          declared_params = declared(params, include_missing: false)
          member   = Member.find_by(uid: declared_params[:uid])
          currency = Currency.find(declared_params[:currency])
          data     = { member: member, currency: currency, blockchain_key: declared_params[:blockchain_key] }.merge!(declared_params.slice(:amount, :tid))
          deposit  = ::Deposits::Fiat.new(data)

          if deposit.save
            present deposit, with: API::V2::Admin::Entities::Deposit
            status 201
          else
            body errors: deposit.errors.full_messages
            status 422
          end
        end

        desc 'Creates new crypto refund',
          success: API::V2::Admin::Entities::Refund
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.deposit.non_integer_type' },
                   desc: -> { 'Deposit id' }
          requires :address,
                   desc: -> { API::V2::Admin::Entities::Refund.documentation[:address][:desc] }
        end
        post '/deposits/:id/refund' do
          admin_authorize! :write, ::Deposit

          deposit = Deposit.find(params[:id])

          refund = ::Refund.new(deposit: deposit, address: params[:address])

          if refund.save
            present refund, with: API::V2::Admin::Entities::Refund
          else
            body errors: refund.errors.full_messages
            status 422
          end
        end

        desc 'Returns deposit address for account you want to deposit to by currency and uid.',
          success: API::V2::Admin::Entities::Deposit
        params do
          requires :uid,
                   values: { value: -> (v) { Member.exists?(uid: v) }, message: 'admin.deposit.user_doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:uid][:desc] }
          requires :currency,
                   values: { value: -> { Currency.codes }, message: 'admin.deposit.currency_doesnt_exist' },
                   as: :currency_id,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:currency][:desc] }
          requires :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.beneficiary.blockchain_key_doesnt_exist' },
                   desc: 'Blockchain key of the requested beneficiary'
          given :currency_id do
            optional :address_format,
                    type: String,
                    values: { value: -> { %w[legacy cash] }, message: 'admin.deposit.invalid_address_format' },
                    validate_currency_address_format: { value: true, prefix: 'admin.deposit' },
                    desc: 'Address format legacy/cash'
          end
        end
        post '/deposit_address' do
          admin_authorize! :create, ::PaymentAddress

          member   = Member.find_by!(uid: params[:uid])
          currency = Currency.find_by!(id: params[:currency_id])
          blockchain_currency = BlockchainCurrency.find_network(params[:blockchain_key], currency.id)
          error!({ errors: ['admin.deposit.network_not_found'] }, 422) unless blockchain_currency.present?

          wallet = Wallet.active_deposit_wallet(currency.id, blockchain_currency.blockchain_key)

          unless wallet.present?
            error!({ errors: ['admin.deposit.wallet_not_found'] }, 422)
          end

          if blockchain_currency.deposit_enabled
            payment_address = member.payment_address(wallet.id)
            present payment_address, with: API::V2::Entities::PaymentAddress, address_format: params[:address_format]
            status 201
          else
            body errors: ["admin.deposit.deposit_disabled"]
            status 422
          end
        end
      end
    end
  end
end
