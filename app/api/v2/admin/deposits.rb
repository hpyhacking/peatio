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
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:blockchain_txid][:desc] }
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
      end
    end
  end
end
