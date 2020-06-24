# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class TradingFees < Grape::API
        helpers ::API::V2::Admin::Helpers

        desc 'Returns trading_fees table as paginated collection',
          is_array: true,
          success: API::V2::Entities::TradingFee
        params do
          optional :group,
                   type: String,
                   desc: -> { API::V2::Entities::TradingFee.documentation[:group][:desc] },
                   coerce_with: ->(c) { c.strip.downcase }
          optional :market_id,
                   type: String,
                   desc: -> { API::V2::Entities::TradingFee.documentation[:market_id][:desc] },
                   values: { value: -> { ::Market.ids.append(::TradingFee::ANY) },
                             message: 'public.trading_fee.market_doesnt_exist' }
          use :pagination
          use :ordering
        end
        get '/trading_fees' do
          ransack_params = API::V2::Admin::Helpers::RansackBuilder.new(params)
                             .eq(:group, :market_id)
                             .build

          search = TradingFee.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(Rails.cache.fetch("trading_fees_#{params}", expires_in: 600) { search.result.load.to_a }), with: API::V2::Entities::TradingFee
        end
      end
    end
  end
end
