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
                   values: { value: -> { Deposit::STATES.map(&:to_s) }, message: 'admin.deposit.invalid_state' },
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
          use :uid
          use :currency
          use :currency_type
          use :date_picker
          use :pagination
          use :ordering
        end
        get '/deposits' do
          authorize! :read, Deposit

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:id, :txid, :tid, :address)
                             .translate(state: :aasm_state, uid: :member_uid, currency: :currency_id)
                             .with_daterange
                             .merge(type_eq: params[:type].present? ? "Deposits::#{params[:type]}" : nil)
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
          authorize! :write, Deposit

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
          requires :amount,
                   type: { value: BigDecimal, message: 'admin.deposit.non_decimal_amount' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:amount][:desc] }
          optional :tid,
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:tid][:desc] }
        end
        post '/deposits/new' do
          authorize! :create, Deposit

          declared_params = declared(params, include_missing: false)
          member   = Member.find_by(uid: declared_params[:uid])
          currency = Currency.find(declared_params[:currency])
          data     = { member: member, currency: currency }.merge!(declared_params.slice(:amount, :tid))
          deposit  = ::Deposits::Fiat.new(data)

          if deposit.save
            present deposit, with: API::V2::Admin::Entities::Deposit
            status 201
          else
            body errors: deposit.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
