# frozen_string_literal: true

module API
  module V2
    module Public
      class WithdrawLimits < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Returns withdraw limits table as paginated collection',
             is_array: true,
             success: API::V2::Entities::WithdrawLimit
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
          ransack_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                                                                  .eq(:group, :kyc_level)
                                                                  .build

          search = WithdrawLimit.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(Rails.cache.fetch("withdraw_limits_#{params}", expires_in: 600) { search.result.load.to_a }), with: API::V2::Entities::WithdrawLimit
        end
      end
    end
  end
end
