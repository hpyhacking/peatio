# frozen_string_literal: true

module API
  module V2
    class ImportConfigsHelper
      def process(params)
        YAML.load(params[:tempfile]).sort.each do |row|
          type = row[0]
          data = row[1]
          next unless type

          data.each do |record|
            record = record.compact.symbolize_keys!
            case type
            when "blockchains"
              ::Blockchain.create!(record) unless ::Blockchain.find_by(key: record[:key])
            when "currencies"
              Currency.create!(record.except(:networks)) unless Currency.find_by(code: record[:id])
              if record[:networks].present?
                BlockchainCurrency.transaction do
                  record[:networks].each do |network|
                    next if BlockchainCurrency.exists?(currency_id: record.fetch(:id), blockchain_key: network.fetch('blockchain_key'))
                    BlockchainCurrency.create!(network.merge(currency_id: record.fetch(:id)))
                  end
                end
              end
            when "wallets"
              if record[:currency_ids].is_a?(String)
                record[:currency_ids] = record[:currency_ids].split(',')
              end
              ::Wallet.create!(record) unless ::Wallet.find_by(name: record[:name])
            when "markets"
              import_market(record)
            else
              Rails.logger.info { "The #{type} is not supported" }
            end
          rescue StandardError => e
            Rails.logger.error { e.message }
          end
        rescue StandardError => e
          Rails.logger.error { e.message }
        end
      end

      def import_market(hash)
        return if ::Market.exists?(id: hash.fetch(:id))
        enabled = hash.delete(:enabled)
        hash[:state] ||= enabled ? :enabled : :disabled

        legacy_keys_mappings = { ask_unit:       :base_unit,
                                  bid_unit:       :quote_unit,
                                  ask_precision:  :amount_precision,
                                  bid_precision:  :price_precision,
                                  min_ask_price:  :min_price,
                                  max_bid_price:  :max_price,
                                  min_ask_amount: :min_amount,
                                  min_bid_amount: :min_amount }

        legacy_keys_mappings.each do |old_key, new_key|
          legacy_key_value = hash.delete(old_key)
          hash[new_key] ||= legacy_key_value
        end

        engine = ::Engine.find_by(name: hash[:engine_name])
        if engine.present?
          hash.delete :engine_name
          hash[:engine_id] = engine.id
          ::Market.create!(hash)
        else
          Rails.logger.error "Engine doesn't exist"
        end
      end
    end
  end
end
