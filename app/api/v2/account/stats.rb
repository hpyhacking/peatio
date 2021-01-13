# frozen_string_literal: true

module API
  module V2
    module Account
      class Stats < Grape::API
        desc 'Get assets pnl calculated into one currency'
        params do
          optional :pnl_currency,
                   type: String,
                   values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'pnl.currency.doesnt_exist' },
                   desc: 'Currency code in which the PnL is calculated'
        end
        get '/stats/pnl' do
          user_authorize! :read, ::StatsMemberPnl

          query = 'SELECT pnl_currency_id, currency_id, total_credit, total_debit, total_credit_value, total_debit_value, ' \
                  'total_credit_value / NULLIF(total_credit, 0) "average_buy_price", ' \
                  'total_debit_value / NULLIF(total_debit, 0) "average_sell_price", ' \
                  'average_balance_price, total_balance_value ' \
                  'FROM stats_member_pnl WHERE member_id = ?'
          conditions = [current_user.id]

          if params[:pnl_currency].present?
            query += ' AND pnl_currency_id = ?'
            conditions << params[:pnl_currency]
          end

          squery = ActiveRecord::Base.sanitize_sql_for_conditions([query] + conditions)
          result = ActiveRecord::Base.connection.exec_query(squery).to_hash
          present result.each(&:symbolize_keys!), with: API::V2::Entities::Pnl
        end
      end
    end
  end
end
