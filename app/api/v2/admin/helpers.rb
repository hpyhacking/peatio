# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Helpers
        extend ::Grape::API::Helpers

        class RansackBuilder
          # RansackBuilder creates a hash in a format ransack accepts
          # eq(:column) generetes a pair column_eq: params[:column]
          # translate(:column1 => :column2) generates a pair column2_eq: params[:column1]
          # merge allows to append additional selectors in
          # build returns prepared hash

          attr_reader :build

          def initialize(params)
            @params = params
            @build = {}
          end

          def merge(opt)
            @build.merge!(opt)
            self
          end

          def with_daterange
            @build.merge!("#{@params[:range]}_at_gteq" => @params[:from])
            @build.merge!("#{@params[:range]}_at_lteq" => @params[:to])
            self
          end

          def translate(opt)
            opt.each { |k, v| @build.merge!("#{v}_eq" => @params[k]) }
            self
          end

          def translate_in(opt)
            opt.each { |k, v| @build.merge!("#{v}_in" => @params[k]) }
            self
          end

          def in(*keys)
            keys.each { |k| @build.merge!("#{k}_in" => @params[k]) }
            self
          end

          def eq(*keys)
            keys.each { |k| @build.merge!("#{k}_eq" => @params[k]) }
            self
          end
        end

        class WalletOverviewBuilder
          def initialize(currencies, blockchain_currencies)
            @currencies = currencies
            @blockchain_currencies = blockchain_currencies
          end

          def info
            result = []
            # Select from active currencies ordered by position
            @currencies.ordered.each_with_index do |currency, index|
              result[index] = { id: index + 1, name: currency.name, code: currency.code }

              # Initialize blockchains
              result[index][:blockhains] = []
              # Select all currency active networks
              @blockchain_currencies.where(currency_id: currency).each_with_index do |b_currency, b_index|
                result[index][:blockhains].push({ blockchain_key: b_currency.blockchain_key,
                                                  blockchain_name: b_currency.blockchain.name })
                # Initialize blockchain balances
                result[index][:blockhains][b_index][:balances] = []
                # Select wallets linked to currency
                wallet_ids = CurrencyWallet.where(currency_id: currency.id).pluck(:wallet_id)
                Wallet.active.where(id: wallet_ids, blockchain_key: b_currency.blockchain_key).each do |w|
                  balance = w.balance.present? ? w.balance[currency.id] : nil
                  current_balance = balance == Wallet::NOT_AVAILABLE || balance == nil ? 0 : balance.to_d
                  wallet_obj = { kind: w.kind, balance: current_balance }
                  # Expose updated_at in case of late balance update
                  wallet_obj.merge!(updated_at: w.updated_at) if w.updated_at < 5.minute.ago

                  result[index][:blockhains][b_index][:balances].push(wallet_obj)
                end

                # Calculate total_balance/estimated_total per each network
                total = result[index][:blockhains][b_index][:balances].inject(0) {|sum, hash| sum + hash[:balance]}
                result[index][:blockhains][b_index].merge!(total: total, estimated_total: currency.price * total)
              end

              # Calculate total balance per each currency
              total = result[index][:blockhains].inject(0) {|sum, hash| sum + hash[:total]}
              estimated_total = result[index][:blockhains].inject(0) {|sum, hash| sum + hash[:estimated_total]}
              result[index].merge!(total: total, estimated_total: estimated_total)
            end

            result
          end
        end

        params :currency_type do
          optional :type,
                   type: String,
                   values: { value: ::Currency.types.map(&:to_s), message: 'admin.currency.invalid_type' },
                   desc: -> { API::V2::Admin::Entities::Currency.documentation[:type][:desc] }
        end

        params :currency do
          optional :currency,
                   values: { value: -> { Currency.codes(bothcase: true) }, message: 'admin.currency.doesnt_exist' },
                   desc: -> { API::V2::Admin::Entities::Deposit.documentation[:currency][:desc] }
        end

        params :uid do
          optional :uid,
                   values:  { value: -> (v) { Member.exists?(uid: v) }, message: 'admin.user.doesnt_exist' },
                   desc: -> { API::V2::Entities::Member.documentation[:uid][:desc] }
        end

        params :pagination do
          optional :limit,
                   type: { value: Integer, message: 'admin.pagination.non_integer_limit' },
                   values: { value: 1..1000, message: 'admin.pagination.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned paginations. Defaults to 100.'
          optional :page,
                   type: { value: Integer, message: 'admin.pagination.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
        end

        params :ordering do
          optional :ordering,
                   values: { value: %w(asc desc), message: 'admin.pagination.invalid_ordering' },
                   default: 'asc',
                   desc: 'If set, returned values will be sorted in specific order, defaults to \'asc\'.'
          optional :order_by,
                   default: 'id',
                   desc: 'Name of the field, which result will be ordered by.'
        end

        params :date_picker do
          optional :range,
                   default: 'created',
                   values: { value: -> { %w[created updated completed] } },
                   desc: 'Date range picker, defaults to \'created\'.'
          optional :from,
                   type: { value: Time, message: 'admin.filter.range_from_invalid' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                     'If set, only entities FROM the time will be retrieved.'
          optional :to,
                   type: { value: Time, message: 'admin.filter.range_to_invalid' },
                   desc: 'An integer represents the seconds elapsed since Unix epoch.'\
                     'If set, only entities BEFORE the time will be retrieved.'
        end
      end
    end
  end
end
