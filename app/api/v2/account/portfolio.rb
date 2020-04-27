# frozen_string_literal: true

module API
  module V2
    module Account
      class Portfolio < Grape::API
        desc 'Get Crypto-Currency portfolio'
        params do
          requires :quote_unit,
                   type: String,
                   values: { value: ->(v) { v.in?(::Market.pluck(:quote_unit)) },
                             message: 'account.portfolio.quote_unit_doesnt_exist' },
                   desc: 'Markets quote unit for user portfolio calculation'
        end
        get '/portfolio' do
          query = 'SELECT m.base_unit, SUM(total) `total`, SUM(total) / SUM(amount) `price` ' \
                        'FROM trades t ' \
                        'JOIN markets m ' \
                        'ON t.market_id = m.id ' \
                  "WHERE ((taker_id = ? AND taker_type = 'buy') OR (maker_id = ? AND taker_type = 'sell')) AND (m.quote_unit = ?) " \
                  'GROUP BY t.market_id'

          sanitized_query = ActiveRecord::Base.sanitize_sql_for_conditions([query, current_user.id, current_user.id, params[:quote_unit]])
          result = ActiveRecord::Base.connection.exec_query(sanitized_query).to_hash
          present paginate(result.each(&:symbolize_keys!)), with: API::V2::Entities::Portfolio
        end
      end
    end
  end
end
