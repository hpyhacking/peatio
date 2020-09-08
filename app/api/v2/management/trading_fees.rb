# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class TradingFees < Grape::API
        desc 'Returns trading_fees table as paginated collection' do
          @settings[:scope] = :read_trading_fees
        end
        params do
          optional :group,
                   type: String,
                   desc: 'Member group'
          optional :market_id,
                   type: String,
                   desc: 'Market id',
                   values: { value: -> { ::Market.ids.append(::TradingFee::ANY) },
                             message: 'Market does not exist' }
          optional :page, type: Integer, default: 1, integer_gt_zero: true, desc: 'The page number (defaults to 1).'
          optional :limit, type: Integer, default: 100, range: 1..1000, desc: 'The number of objects per page (defaults to 100, maximum is 1000).'
        end
        post '/fee_schedule/trading_fees' do
          TradingFee
            .order(id: :desc)
            .tap { |t| t.where!(market_id: params[:market_id]) if params[:market_id] }
            .tap { |t| t.where!(group: params[:group]) if params[:group] }
            .tap { |q| present paginate(q), with: API::V2::Entities::TradingFee }
          status 200
        end
      end
    end
  end
end
