# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Trades < Grape::API

        desc 'Returns trades as paginated collection.' do
          @settings[:scope] = :read_trades
          success API::V2::Management::Entities::Trade
        end
        params do
          optional :uid,      type: String,  desc: 'The shared user ID.'
          optional :market, type: String,
                   values: { value: -> { ::Market.active.ids },
                   message: 'Market does not exist' }
          optional :page,     type: Integer, default: 1,   integer_gt_zero: true, desc: 'The page number (defaults to 1).'
          optional :limit,    type: Integer, default: 100, range: 1..1000, desc: 'The number of objects per page (defaults to 100, maximum is 1000).'
        end
        post '/trades' do
          market = ::Market.find(params[:market]) if params[:market].present?
          member = Member.find_by!(uid: params[:uid]) if params[:uid].present?

          Trade
            .order(id: :desc)
            .includes(:maker, :taker)
            .tap { |q| q.where!(market: market) if market }
            .tap { |q| q.where!("maker_id = #{member.id} OR taker_id = #{member.id}") if member }
            .page(params[:page])
            .per(params[:limit])
            .tap { |q| present q, with: API::V2::Management::Entities::Trade }
          status 200
        end
      end
    end
  end
end
