# frozen_string_literal: true

module API
  module V2
    module Admin
      class WithdrawLimits < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Returns withdraw limits table as paginated collection',
             is_array: true,
             success: API::V2::Admin::Entities::WithdrawLimit
        params do
          optional :group,
                   type: String,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:group][:desc] },
                   coerce_with: ->(c) { c.strip.downcase }
          optional :kyc_level,
                   type: String,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:kyc_level][:desc] }
          use :pagination
          use :ordering
        end
        get '/withdraw_limits' do
          admin_authorize! :read, ::WithdrawLimit

          ransack_params = Helpers::RansackBuilder.new(params)
                                                  .eq(:group, :kyc_level)
                                                  .build

          search = WithdrawLimit.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Entities::WithdrawLimit
        end

        desc 'It creates withdraw limits record',
             success: API::V2::Entities::WithdrawLimit
        params do
          requires :limit_24_hour,
                   type: { value: BigDecimal, message: 'admin.withdraw_limit.non_decimal_limit_24_hour' },
                   values: { value: ->(p) { p && p >= 0 }, message: 'admin.withdraw_limit.invalid_limit_24_hour' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:limit_24_hour][:desc] }
          requires :limit_1_month,
                   type: { value: BigDecimal, message: 'admin.withdraw_limit.non_decimal_limit_1_month' },
                   values: { value: ->(p) { p && p >= 0 }, message: 'admin.withdraw_limit.invalid_limit_1_month' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:limit_1_month][:desc] }
          optional :group,
                   type: String,
                   default: ::WithdrawLimit::ANY,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:group][:desc] }
          optional :kyc_level,
                   type: String,
                   default: ::WithdrawLimit::ANY,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:kyc_level][:desc] }
        end
        post '/withdraw_limits' do
          admin_authorize! :create, ::WithdrawLimit

          withdraw_limit = ::WithdrawLimit.new(declared(params))
          if withdraw_limit.save
            present withdraw_limit, with: API::V2::Entities::WithdrawLimit
            status 201
          else
            body errors: withdraw_limit.errors.full_messages
            status 422
          end
        end

        desc 'It updates withdraw limits record',
             success: API::V2::Entities::WithdrawLimit
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.withdraw_limit.non_integer_id' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:id][:desc] }
          optional :limit_24_hour,
                   type: { value: BigDecimal, message: 'admin.withdraw_limit.non_decimal_limit_24_hour' },
                   values: { value: ->(p) { p && p >= 0 }, message: 'admin.withdraw_limit.invalid_limit_24_hour' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:limit_24_hour][:desc] }
          optional :limit_1_month,
                   type: { value: BigDecimal, message: 'admin.withdraw_limit.non_decimal_limit_1_month' },
                   values: { value: ->(p) { p && p >= 0 }, message: 'admin.withdraw_limit.invalid_limit_1_month' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:limit_1_month][:desc] }
          optional :kyc_level,
                   type: String,
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:kyc_level][:desc] }
          optional :group,
                   type: String,
                   coerce_with: ->(c) { c.strip.downcase },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:group][:desc] }
        end
        put '/withdraw_limits' do
          admin_authorize! :update, ::WithdrawLimit

          withdraw_limit = ::WithdrawLimit.find(params[:id])
          if withdraw_limit.update(declared(params, include_missing: false))
            present withdraw_limit, with: API::V2::Entities::WithdrawLimit
          else
            body errors: withdraw_limit.errors.full_messages
            status 422
          end
        end

        desc 'It deletes withdraw limits record',
             success: API::V2::Entities::WithdrawLimit
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.withdraw_limit.non_integer_id' },
                   desc: -> { API::V2::Entities::WithdrawLimit.documentation[:id][:desc] }
        end
        delete '/withdraw_limits/:id' do
          admin_authorize! :delete, ::WithdrawLimit

          present WithdrawLimit.destroy(params[:id]), with: API::V2::Entities::WithdrawLimit
        end
      end
    end
  end
end
