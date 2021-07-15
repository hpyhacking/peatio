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

          # Result example
          # [{
          #   "id"=>1,"name"=>"Bitcoin","code"=>"btc", "precision"=>8,
          #   "blockchains"=>
          #   [{
          #    "blockchain_key"=>"btc-testnet","blockchain_name"=>"Bitcoin Testnet",
          #    "network"=>"BEP-2","balances"=>[{"kind"=>"hot", "balance"=>0}, {"kind"=>"deposit", "balance"=>0}],
          #    "total"=>0,"estimated_total"=>"0.0"
          #   }],
          #   "total"=>0, "deposit_total_balance"=>0, "fee_total_balance"=>0, "hot_total_balance"=>0,
          #   "warm_total_balance"=>0, "cold_total_balance"=>0, "estimated_total"=>"0.0"
          # }]
          def info
            # Select from active currencies ordered by position
            @currencies.ordered.each_with_object([]).with_index do |(currency, result), index|
              # Information about currency
              result[index] = { id: index + 1, name: currency.name, code: currency.code, precision: currency.precision }

              wallet_ids = CurrencyWallet.where(currency_id: currency.id).pluck(:wallet_id)
              active_wallets = Wallet.active.where(id: wallet_ids)
              uniq_blockchain_keys = active_wallets.pluck(:blockchain_key).uniq

              result[index][:blockchains] = []

              # Iterate over unique blockchain keys for existing wallets
              uniq_blockchain_keys.each_with_index do |blockchain_key, b_index|
                blockchain = Blockchain.find_by(key: blockchain_key)
                # Information about blockchchain per specific currency
                result[index][:blockchains].push({ blockchain_key:  blockchain_key,
                                                   blockchain_name: blockchain.name,
                                                   network:         blockchain.protocol})
                wallets_per_blockchain = active_wallets.where(blockchain_key: blockchain_key)
                # Information about wallet per specific blockchain
                result[index][:blockchains][b_index][:balances] = wallet_info(wallets_per_blockchain, currency.id)

                wallet_total = calculate_wallet_total(result[index][:blockchains][b_index][:balances], currency.price)
                result[index][:blockchains][b_index].merge!(wallet_total)
              end

              # Information about total values in wallets per kind for specific currency
              wallets_total_per_kind = calculate_wallet_per_kind_total(result[index][:blockchains])
              result[index].merge!(wallets_total_per_kind)

              global_total = calculate_global_total(result[index][:blockchains])
              result[index].merge!(global_total)
            end
          end

          private

          def wallet_info(active_wallets, currency_id)
            active_wallets.each_with_object([]) do |w, hash|
              balance = w.balance.present? ? w.balance[currency_id] : nil
              # If there is no balance system will assign balance to 0 value
              current_balance = balance == Wallet::NOT_AVAILABLE || balance == nil ? 0 : balance.to_d
              wallet_obj = { kind: w.kind, balance: current_balance }
              # Expose updated_at in case of late balance update
              wallet_obj.merge!(updated_at: w.updated_at) if w.updated_at < 5.minute.ago
              hash << wallet_obj
            end
          end

          def calculate_wallet_total(hash, currency_price)
            total = hash.inject(0) {|sum, hash| sum + hash[:balance]}
            estimated_total = currency_price * total
            { total: total, estimated_total: estimated_total}
          end

          def calculate_wallet_per_kind_total(blockchains)
            blockchains.each_with_object({}) do |item, hash|
              existing_kinds = Wallet::ENUMERIZED_KINDS.keys.map(&:to_s)
              existing_kinds.map do |wallet_kind|
                res = item[:balances].select {|balance| balance[:kind] == wallet_kind }
                total_balance = res.present? ? res[0][:balance].to_d : 0
                key = "#{wallet_kind}_total_balance"
                hash.merge!("#{key}": hash[key.to_sym].to_d + total_balance)
              end
            end
          end

          def calculate_global_total(hash)
            total = hash.inject(0) {|sum, hash| sum + hash[:total]}
            estimated_total = hash.inject(0) {|sum, hash| sum + hash[:estimated_total]}
            { total: total, estimated_total: estimated_total }
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
                   default: 'desc',
                   desc: 'If set, returned values will be sorted in specific order, defaults to \'desc\'.'
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
