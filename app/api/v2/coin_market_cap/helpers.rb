# frozen_string_literal: true

module API
  module V2
    module CoinMarketCap
      module Helpers
        MILLISECONDS_IN_SECOND = 1000

        def format_summary(ticker, market)
          lowest_ask = OrderAsk.get_depth(market.symbol)
          highest_bid = OrderBid.get_depth(market.symbol)
          {
            trading_pairs:            market.underscore_name,            # mandatory [string]: Identifier of a ticker with delimiter to separate base/quote
            base_currency:            market.base_unit.upcase,           # recommended [string]: Symbol/currency code of base currency
            quote_currency:           market.quote_unit.upcase,          # recommended [string]: Symbol/currency code of base currency
            last_price:               ticker[:last],                     # mandatory [decimal]: Last transacted price of base currency based on given quote currency
            lowest_ask:               lowest_ask.flatten.first.to_d,     # mandatory [decimal]: Lowest Ask price of base currency based on given quote currency
            highest_bid:              highest_bid.flatten.first.to_d,    # mandatory [decimal]: Highest bid price of base currency based on given quote currency
            base_volume:              ticker[:amount],                   # mandatory [decimal]: 24-hr volume of market pair denoted in BASE currency
            quote_volume:             ticker[:volume],                   # mandatory [decimal]: 24-hr volume of market pair denoted in QUOTE currency
            price_change_percent_24h: price_change_percent_24h(ticker),  # mandatory [decimal]: 24-hr % price change of market pair
            highest_price_24h:        ticker[:high],                     # mandatory [decimal]: Highest price of base currency based on given quote currency in the last 24-hrs
            lowest_price_24h:         ticker[:low]                       # mandatory [decimal]: Lowest price of base currency based on given quote currency in the last 24-hrs
          }
        end

        def format_tickers(markets)
          markets.each_with_object({}) do |market, h|
            ticker = TickersService[market].ticker
            unified_base_crypto_id = market.base.coin? ? unified_cryptoasset_id(market.base_unit) : nil
            unified_quote_crypto_id = market.quote.coin? ? unified_cryptoasset_id(market.quote_unit) : nil
            h[market.underscore_name.to_s] = {
              base_id: unified_base_crypto_id,            # recommended [integer]: The quote pair Unified Cryptoasset ID
              quote_id: unified_quote_crypto_id,          # recommended [integer]: The base pair Unified Cryptoasset ID
              last_price: ticker[:last],                  # mandatory [decimal]: Last transacted price of base currency based on given quote currenc
              base_volume: ticker[:amount],               # mandatory [decimal]: 24-hour trading volume denoted in BASE currency
              quote_volume: ticker[:volume],              # mandatory [decimal]: 24 hour trading volume denoted in QUOTE currency
              isFrozen: market.state == 'enabled' ? 0 : 1 # recommended [integer]: Indicates if the market is currently enabled (0) or disabled (1)
            }.compact
          end
        end

        def format_trade(trade)
          {
            trade_id:     trade[:id],                                  # mandatory [integer]: A unique ID associated with the trade for the currency pair transaction
            price:        trade[:price],                               # mandatory [decimal]: Last transacted price of base currency based on given quote currency
            base_volume:  trade[:amount],                              # mandatory [decimal]: Transaction amount in BASE currency
            quote_volume: trade[:total],                               # mandatory [decimal]: Transaction amount in QUOTE currency
            timestamp:    trade[:created_at] * MILLISECONDS_IN_SECOND, # mandatory [integer]: Unix timestamp in milliseconds for when the transaction occurred
            type:         trade[:taker_type]                           # mandatory [string]: Used to determine whether or not the transaction originated as a buy or sell
          }
        end

        def format_orderbook(asks, bids)
          {
            timestamp: DateTime.now.strftime('%Q').to_i, # mandotory [decimal]: Unix timestamp in milliseconds for when the last updated time occurred
            asks:      asks,                             # mandotory [decimal]: The offer price and quantity for each bid order
            bids:      bids                              # mandotory [decimal]: The ask price and quantity for each ask order.
          }
        end

        def format_currencies(currencies)
          currencies.each_with_object({}) do |currency, h|
            h[currency.id.upcase.to_s] = {
              name: currency.name,                                         # recommended [string]: Full name of cryptocurrency
              unified_cryptoasset_id: unified_cryptoasset_id(currency.id), # recommended [integer]: Unique ID of cryptocurrency assigned by Unified Cryptoasset ID
            }.compact
          end
        end

        # Only for crypto currencies
        def unified_cryptoasset_id(currency_id)
          # System will get response in such format [{:id=>1,:name=>"Bitcoin",:symbol=>"BTC"}]
          ::CoinMarketCap.default_client.get(symbol: currency_id)[0][:id]
        rescue ::Faraday::Error, ::CoinMarketCap::Error => e
          Rails.logger.warn e
          # In format methods we skipped all nil values with compact method
          # As unified_cryptoasset_id is only recommended field
          nil
        end

        # System use this methods instead of ticker[:price_change_percent]
        # because we dont need percentage symbols here
        def price_change_percent_24h(ticker)
          ticker[:open].to_d.zero? ? '0.0' : (ticker[:last].to_d - ticker[:open].to_d) / ticker[:open].to_d
        end
      end
    end
  end
end
