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
                   values: { value: ->(v) { (Array.wrap(v) - Withdraw::STATES.map(&:to_s)).blank? }, message: 'admin.withdraw.invalid_state' },
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:state][:desc] }
          optional :blockchain_key,
                   values: { value: -> { ::Blockchain.pluck(:key) }, message: 'admin.withdraw.blockchain_key_doesnt_exist' },
                   desc: 'Blockchain key of the requested withdrawal'
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
          optional :wallet_type,
                   values: { value: ->(v) { (Array.wrap(v.to_sym) - Wallet.gateways).blank? }, message: 'admin.withdraw.invalid_wallet_type' },
                   desc: -> { 'Select withdraw that can be processed from wallets with given type e.g. patiry' }
          use :uid
          use :currency
          use :currency_type
          use :date_picker
          use :pagination
          use :ordering
        end
        get '/withdraws' do
          admin_authorize! :read, ::Withdraw

          ransack_params = Helpers::RansackBuilder.new(params)
                                                  .eq(:id, :txid, :rid, :tid, :blockchain_key)
                                                  .translate(uid: :member_uid, currency: :currency_id)
                                                  .with_daterange
                                                  .merge(type_eq: params[:type].present? ? "Withdraws::#{params[:type].capitalize}" : nil)
                                                  .merge(aasm_state_in: params[:state])
                                                  .build

          search = Withdraw.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          if params[:wallet_type].present?
            present paginate(search.result
                            .where(currency: Currency.joins(:wallets)
                            .where(wallets: { id: Wallet.where(gateway: params[:wallet_type]) }))),
                    with: API::V2::Admin::Entities::Withdraw
          else
            present paginate(search.result), with: API::V2::Admin::Entities::Withdraw
          end
        end

        desc 'Get withdraw by ID.',
             success: API::V2::Admin::Entities::Withdraw
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.withdraw.non_integer_id' },
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
        end
        get '/withdraws/:id' do
          admin_authorize! :read, ::Withdraw

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
          admin_authorize! :update, ::Withdraw

          declared_params = declared(params, include_missing: false)

          withdraw = Withdraw.find(declared_params[:id])

          if withdraw.currency.fiat? && declared_params[:txid].present?
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

        desc 'Update withdraw request',
             success: API::V2::Admin::Entities::Withdraw
        params do
          requires :id,
                   type: Integer,
                   desc: -> { API::V2::Admin::Entities::Withdraw.documentation[:id][:desc] }
          optional :metadata,
                   type: JSON,
                   desc: 'Optional metadata to be applied to the transaction.'
        end
        put '/withdraws' do
          admin_authorize! :update, ::Withdraw

          declared_params = declared(params, include_missing: false)
          withdraw = Withdraw.find(declared_params[:id])

          declared_params[:metadata] = withdraw.metadata.merge(declared_params[:metadata]) if declared_params[:metadata].present?
          if withdraw.update(declared_params)
            present withdraw, with: API::V2::Admin::Entities::Withdraw
          else
            body errors: withdraw.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
