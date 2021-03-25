# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
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
                             message: 'admin.trading_fee.market_doesnt_exist' }
          use :pagination
          use :ordering
        end
        get '/trading_fees' do
          admin_authorize! :read, ::TradingFee

          ransack_params = Helpers::RansackBuilder.new(params)
                             .eq(:group, :market_id)
                             .build

          search = TradingFee.ransack(ransack_params)
          search.sorts = "#{params[:order_by]} #{params[:ordering]}"

          present paginate(search.result), with: API::V2::Entities::TradingFee
        end

        desc 'It creates trading fees record',
          success: API::V2::Entities::TradingFee
        params do
          requires :maker,
                   type: { value: BigDecimal, message: 'admin.trading_fee.non_decimal_maker' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.trading_fee.invalid_maker' },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:maker][:desc] }
          requires :taker,
                   type: { value: BigDecimal, message: 'admin.trading_fee.non_decimal_taker' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.trading_fee.invalid_taker' },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:taker][:desc] }
          optional :group,
                   type: String,
                   default: ::TradingFee::ANY,
                   desc: -> { API::V2::Entities::TradingFee.documentation[:group][:desc] }
          optional :market_id,
                   type: String,
                   desc: -> { API::V2::Entities::TradingFee.documentation[:market_id][:desc] },
                   default: ::TradingFee::ANY,
                   values: { value: -> { ::Market.ids.append(::TradingFee::ANY) },
                             message: 'admin.trading_fee.market_doesnt_exist' }
        end
        post '/trading_fees/new' do
          admin_authorize! :create, ::TradingFee

          trading_fee = ::TradingFee.new(declared(params))
          if trading_fee.save
            present trading_fee, with: API::V2::Entities::TradingFee
            status 201
          else
            body errors: trading_fee.errors.full_messages
            status 422
          end
        end

        desc 'It updates trading fees record',
          success: API::V2::Entities::TradingFee
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.trading_fee.non_integer_id' },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:id][:desc] }
          optional :maker,
                   type: { value: BigDecimal, message: 'admin.trading_fee.non_decimal_maker' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.trading_fee.invalid_maker' },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:maker][:desc] }
          optional :taker,
                   type: { value: BigDecimal, message: 'admin.trading_fee.non_decimal_taker' },
                   values: { value: -> (p){ p && p >= 0 }, message: 'admin.trading_fee.invalid_taker' },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:taker][:desc] }
          optional :group,
                   type: String,
                   coerce_with: ->(c) { c.strip.downcase },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:group][:desc] }
          optional :market_id,
                   type: String,
                   desc: -> { API::V2::Entities::TradingFee.documentation[:market_id][:desc] },
                   values: { value: -> { ::Market.ids.append(::TradingFee::ANY) },
                             message: 'admin.trading_fee.market_doesnt_exist' }
        end
        post '/trading_fees/update' do
          admin_authorize! :update, ::TradingFee

          trading_fee = ::TradingFee.find(params[:id])
          if trading_fee.update(declared(params, include_missing: false))
            present trading_fee, with: API::V2::Entities::TradingFee
          else
            body errors: trading_fee.errors.full_messages
            status 422
          end
        end

        desc 'It deletes trading fees record',
          success: API::V2::Entities::TradingFee
        params do
          requires :id,
                   type: { value: Integer, message: 'admin.trading_fee.non_integer_id' },
                   desc: -> { API::V2::Entities::TradingFee.documentation[:id][:desc] }
        end
        post '/trading_fees/delete' do
          admin_authorize! :delete, ::TradingFee

          present TradingFee.destroy(params[:id]), with: API::V2::Entities::TradingFee
        end
      end
    end
  end
end
