# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Withdraws < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Get all withdraws, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Deposit
        params do
          optional :state,
                   values: { value: -> { Withdraw::STATES.map(&:to_s) }, message: 'admin.withdraw.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:state][:desc] }
          optional :account,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:account][:desc] }
          optional :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
          optional :txid,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:blockchain_txid][:desc] }
          optional :tid,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:tid][:desc] }
          optional :confirmations,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:confirmations][:desc] }
          optional :rid,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:rid][:desc] }
          use :uid
          use :currency
          use :currency_type
          use :date_picker
          use :pagination
          use :ordering
        end
        get '/withdraws' do
          authorize! :read, Withdraw

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:id, :txid, :rid, :tid)
                             .translate(state: :aasm_state, uid: :member_uid, account: :account_id, currency: :currency_id)
                             .with_daterange
                             .merge(type_eq: params[:type].present? ? "Withdraws::#{params[:type]}" : nil)
                             .build

          search = Withdraw.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::Withdraw
        end
      end
    end
  end
end
