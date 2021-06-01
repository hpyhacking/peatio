# encoding: UTF-8
# frozen_string_literal: true

 require_relative '../validations'

module API
  module V2
    module Account
      class Transactions < Grape::API

        before { deposits_must_be_permitted! }
        before { withdraws_must_be_permitted! }

        desc 'Get your transactions history.',
        is_array: true

        params do
          optional :currency,
                   type: String,
                   values: { value: -> { Currency.visible.codes(bothcase: true) }, message: 'account.transactions.currency_doesnt_exist' },
                   desc: 'Currency code'

          optional :order_by,
                   type: String,
                   values: { value: %w(asc desc), message: 'account.transactions.order_by_invalid' },
                   default: 'desc',
                   desc: 'Sorting order'

          optional :time_from,
                   allow_blank: { value: false, message: 'account.transactions.empty_time_from' },
                   type: { value: Integer, message: 'account.transactions.non_integer_time_from' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'

          optional :time_to,
                   type: { value: Integer, message: 'account.transactions.non_integer_time_to' },
                   allow_blank: { value: false, message: 'account.transactions.empty_time_to' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'

          optional :deposit_state,
                   values: { value: ->(v) { (Array.wrap(v) - ::Deposit.aasm.states.map(&:name).map(&:to_s)).blank? }, message: 'account.transactions.invalid_deposit_state' },
                   desc: 'Filter deposits by states.',
                   default: []

          optional :withdraw_state,
                   values: { value: ->(v) { (Array.wrap(v) - Withdraw::STATES.map(&:to_s)).blank? }, message: 'account.transactions.invalid_withdraw_state' },
                   desc: 'Filter withdraws by states.',
                   default: []

          optional :txid,
                   type: String,
                   allow_blank: false,
                   desc: 'Transaction id.'

          optional :limit,
                   type: { value: Integer, message: 'account.transactions.non_integer_limit' },
                   values: { value: 1..1000, message: 'account.transactions.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned transactions. Default to 100.'

          optional :page,
                   type: { value: Integer, message: 'account.transactions.non_integer_page' },
                   values: { value: -> (p){ p.try(:positive?) }, message: 'account.transactions.non_positive_page'},
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'

        end
        get "/transactions" do
          user_authorize! :read, ::Withdraw
          user_authorize! :read, ::Deposit

          deposit_state = params[:deposit_state]&.split(/\W+/)&.join(',')
          withdraw_state = params[:withdraw_state]&.split(/\W+/)&.join(',')

          deposit_sql = "(SELECT d.id, currency_id, blockchain_key, amount, fee, address, aasm_state, NULL AS note, txid, d.created_at, d.updated_at, d.type, b.height - block_number AS confirmations FROM deposits d " \
          "INNER JOIN currencies c ON c.id=d.currency_id LEFT JOIN blockchains b ON b.key=d.blockchain_key WHERE member_id=#{current_user.id} "
          if params[:deposit_state].present?
            deposit_sql += if Rails.configuration.database_adapter.downcase == 'PostgreSQL'.downcase
                             "and aasm_state = any(string_to_array('#{deposit_state}',','))"
                           else
                             "and FIND_IN_SET(aasm_state, '#{deposit_state}')"
                           end
          end

          withdraw_sql = "SELECT w.id, currency_id, blockchain_key, amount, fee, rid, aasm_state, note, txid, w.created_at, w.updated_at, w.type, b.height - block_number AS confirmations FROM withdraws w " \
          "INNER JOIN currencies c ON c.id=w.currency_id LEFT JOIN blockchains b ON b.key=w.blockchain_key WHERE member_id=#{current_user.id} "
          if params[:withdraw_state].present?
            withdraw_sql += if Rails.configuration.database_adapter.downcase == 'PostgreSQL'.downcase
                              "and aasm_state = any(string_to_array('#{withdraw_state}',','))"
                            else
                              "and FIND_IN_SET(aasm_state, '#{withdraw_state}')"
                            end
          end

          sql = "SELECT * FROM " + deposit_sql + "UNION " + withdraw_sql + ") AS transactions ORDER BY updated_at #{params[:order_by].upcase}"

          result = ActiveRecord::Base.connection.exec_query(sql).to_hash

          result.select! { |t|  t['currency_id'] == params[:currency].downcase } if params[:currency].present?
          result.select! { |t|  t['txid'] == params[:txid] } if params[:txid].present?
          result.select! { |t|  t['updated_at'] >= Time.at(params[:time_from]) } if params[:time_from].present?
          result.select! { |t|  t['updated_at'] <= Time.at(params[:time_to]) } if params[:time_to].present?

          present paginate(result.each(&:symbolize_keys!)), with: API::V2::Entities::Transactions
        end
      end
    end
  end
end
