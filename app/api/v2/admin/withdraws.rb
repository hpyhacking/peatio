# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Withdraws < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Get all withdraws, result is paginated.',
          is_array: true,
          success: API::V2::Admin::Entities::Withdraw
        params do
          optional :state,
                   type: Array[String],
                   values: { value: -> { Withdraw::STATES.map(&:to_s) }, message: 'admin.withdraw.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:state][:desc] }
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
                             .translate(uid: :member_uid, currency: :currency_id)
                             .with_daterange
                             .merge(type_eq: params[:type].present? ? "Withdraws::#{params[:type]}" : nil)
                             .merge(aasm_state_in: params[:state])
                             .build

          search = Withdraw.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Admin::Entities::Withdraw
        end

        desc 'Get withdraw by ID.',
             success: API::V2::Admin::Entities::Withdraw
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
        end
        get '/withdraws/:id' do
          authorize! :read, Withdraw

          withdraw = Withdraw.find_by!(id: params[:id])
          present withdraw,
                  with: API::V2::Admin::Entities::Withdraw,
                  with_beneficiary: true
        end

        desc 'Take an action on the withdrawal.',
          success: API::V2::Admin::Entities::Withdraw
        params do
          requires :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
          requires :action,
                   type: String,
                   values: { value: -> { ::Withdraw.aasm.events.map(&:name).map(&:to_s) }, message: 'admin.withdraw.invalid_action' },
                   desc: "Valid actions are #{::Withdraw.aasm.events.map(&:name)}."
          given action: ->(action) { %w[load dispatch success].include?(action) } do
            optional :txid,
                     type: String,
                     desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:blockchain_txid][:desc] }
          end
        end
        post '/withdraws/actions' do
          authorize! :write, Withdraw

          declared_params = declared(params, include_missing: false)

          withdraw = Withdraw.find(declared_params[:id])

          if withdraw.fiat? && declared_params[:txid].present?
            error!({ errors: ['admin.withdraw.redundant_txid'] }, 422)
          end

          transited = withdraw.transaction do
            withdraw.update!(txid: declared_params[:txid]) if declared_params[:txid].present?
            withdraw.public_send("#{declared_params[:action]}!").tap do |success|
              raise ActiveRecord::Rollback unless success
            end
          rescue StandardError
            raise ActiveRecord::Rollback
          end

          if transited
            present withdraw, with: API::V2::Admin::Entities::Withdraw
          else
            body errors: ["admin.withdraw.cannot_#{declared_params[:action]}"]
            status 422
          end
        end
      end
    end
  end
end
