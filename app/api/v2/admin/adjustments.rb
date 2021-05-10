# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Adjustments < Grape::API
        helpers ::API::V2::Admin::Helpers

        namespace :adjustments do
          desc 'Get all adjustments, result is paginated.',
            is_array: true,
            success: API::V2::Admin::Entities::Adjustment
          params do
            use :currency
            use :date_picker
            use :pagination
            use :ordering
            optional :state,
                    type: String,
                    values: { value: -> { Adjustment.aasm.states.map(&:name).map(&:to_s) }, message: 'admin.adjustment.invalid_action' },
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:state][:desc] }
            optional :category,
                    type: String,
                    values: { value: -> { ::Adjustment::CATEGORIES }, message: 'admin.adjustment.invalid_category' },
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:category][:desc] }
          end
          get do
            admin_authorize! :read, ::Adjustment

            ransack_params = Helpers::RansackBuilder.new(params)
                                                    .eq(:state, :category)
                                                    .translate(currency: :currency_id)
                                                    .with_daterange
                                                    .build

            search = Adjustment.ransack(ransack_params)
            search.sorts = "#{params[:order_by]} #{params[:ordering]}"

            present paginate(search.result), with: API::V2::Admin::Entities::Adjustment
          end

          desc 'Get adjustment by ID',
            success: API::V2::Admin::Entities::Adjustment
          params do
            requires :id,
                    type: { value: Integer, message: 'account.adjustment.non_integer_id' },
                    desc: 'Adjsustment Identifier in Database'
          end
          get ':id' do
            admin_authorize! :read, ::Adjustment

            present ::Adjustment.find(params[:id]), with: API::V2::Admin::Entities::Adjustment
          end

          desc 'Create new adjustment.',
            success: API::V2::Admin::Entities::Adjustment
          params do
            requires :reason,
                    type: String,
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:reason][:desc] }
            requires :description,
                    type: String,
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:description][:desc] }
            requires :category,
                    type: String,
                    values: { value: -> { ::Adjustment::CATEGORIES }, message: 'admin.adjustment.invalid_category' },
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:category][:desc] }
            requires :amount,
                    type: { value: BigDecimal, message: 'admin.adjustment.non_decimal_amount' },
                    allow_blank: false,
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:amount][:desc] }
            requires :currency_id,
                    type: String,
                    values: { value: -> { ::Currency.codes }, message: 'admin.adjustment.currency_doesnt_exist' },
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:currency][:desc] }
            requires :asset_account_code,
                    type: { value: Integer, message: 'admin.adjustment.non_integer_asset_account_code' },
                    values: { value: -> { ::Operations::Account.where(type: :asset).pluck(:code) }, message: 'admin.adjustment.invalid_asset_account_code' },
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:asset_account_code][:desc] }
            requires :receiving_account_code,
                    type: { value: Integer, message: 'admin.adjustment.non_integer_receiving_account_code' },
                    values: { value: -> { ::Operations::Account.where.not(type: :asset).pluck(:code) }, message: 'admin.adjustment.invalid_receiving_account_code' },
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:receiving_account_code][:desc] }
            optional :receiving_member_uid,
                    type: String,
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:receiving_account_code][:desc] }
          end
          post '/new' do
            admin_authorize! :create, ::Adjustment

            # Do not accept member_uid if account code is not Liability or Revenue
            # Raise error if there is no :receiving_member_uid for Liability
            operation_klass = ::Operations.klass_for(code: params[:receiving_account_code])
            if operation_klass == ::Operations::Liability && params[:receiving_member_uid].blank?
              error!({ errors: ['admin.adjustment.missing_receiving_member_uid'] }, 422)
            elsif operation_klass == ::Operations::Expense && params[:receiving_member_uid].present?
              error!({ errors: ['admin.adjustment.redundant_receiving_member_uid'] }, 422)
            end

            receiving = ::Operations.build_account_number(currency_id: params[:currency_id],
                                                          account_code: params[:receiving_account_code],
                                                          member_uid: params[:receiving_member_uid])

            adjustment = Adjustment.new(declared(params)
                                        .except(:receiving_account_code, :receiving_member_uid)
                                        .merge(receiving_account_number: receiving,
                                               creator: current_user))
            if adjustment.save
              present adjustment, with: API::V2::Admin::Entities::Adjustment
              status 201
            else
              body errors: adjustment.errors.full_messages
              status 422
            end
          end

          desc 'Accepts adjustment and creates operations or reject adjustment.',
            success: API::V2::Admin::Entities::Adjustment
          params do
            requires :id,
                    type: { value: Integer, message: 'admin.adjustment.non_integer_id' },
                    desc: -> { API::V2::Admin::Entities::Adjustment.documentation[:id][:desc] }
            requires :action,
                    type: String,
                    values: { value: -> { Adjustment.aasm.events.map(&:name).map(&:to_s) }, message: 'admin.adjustment.invalid_action' },
                    desc: "Adjustment action all available actions: #{Adjustment.aasm.events.map(&:name)}"
          end
          post '/action' do
            admin_authorize! :update, ::Adjustment
            adjustment = Adjustment.find(params[:id])

            if adjustment.amount.negative?
              account_number_hash = ::Operations.split_account_number(account_number: adjustment.receiving_account_number)
              member = Member.find_by(uid: account_number_hash[:member_uid])
              if member.present?
                balance = member.get_account(account_number_hash[:currency_id]).balance

                if adjustment.amount.abs() > balance && params[:action] != 'reject'
                  error!({ errors: ['admin.adjustment.user_insufficient_balance'] }, 422)
                end
              end
            end

            if adjustment.public_send("may_#{params[:action]}?")
              # TODO: Add behaviour in case of errors on action.
              adjustment.public_send("#{params[:action]}!", validator: current_user)
              present adjustment, with: API::V2::Admin::Entities::Adjustment
            else
              body errors: ["admin.adjustment.cannot_perform_#{params[:action]}_action"]
              status 422
            end
          end
        end
      end
    end
  end
end
