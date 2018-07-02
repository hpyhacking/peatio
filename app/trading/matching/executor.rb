# encoding: UTF-8
# frozen_string_literal: true

require_relative 'constants'

module Matching
  class Executor
    def initialize(payload)
      @payload = payload
      # NOTE: Run matching engine for disabled markets.
      @market  = Market.find(payload[:market_id])
      @price   = payload[:strike_price].to_d
      @volume  = payload[:volume].to_d
      @funds   = payload[:funds].to_d
    end

    def execute
      execute!
    rescue TradeExecutionError => e
      AMQPQueue.enqueue(:trade_error, e.options)
      [@ask, @bid].each do |order|
        order.with_lock do
          next unless order.state == Order::WAIT
          AMQPQueue.enqueue(:matching, action: 'submit', order: order.to_matching_attributes)
        end
      end
      report_exception_to_screen(e)
      false
    end

    def execute!
      create_trade_and_strike_orders
      publish_trade
      @trade
    end

  private

    def validate!
      raise_error(3001, 'Ask price exceeds strike price.') if @ask.ord_type == 'limit' && @ask.price > @price
      raise_error(3002, 'Bid price is less than strike price.') if @bid.ord_type == 'limit' && @bid.price < @price
      raise_error(3003, 'Ask state isn\'t equal to «wait».') unless @ask.state == Order::WAIT
      raise_error(3004, 'Bid state isn\'t equal to «wait».') unless @bid.state == Order::WAIT
      unless @funds > ZERO && [@ask.volume, @bid.volume].min >= @volume
        raise_error(3005, 'Not enough funds.')
      end
    end

    def trend
      @price >= @market.latest_price ? 'up' : 'down'
    end

    def create_trade_and_strike_orders
      _trend = trend

      ActiveRecord::Base.transaction do
        Order.lock.where(id: [@payload[:ask_id], @payload[:bid_id]]).to_a.tap do |orders|
          @ask = orders.find { |order| order.id == @payload[:ask_id] }
          @bid = orders.find { |order| order.id == @payload[:bid_id] }
        end

        validate!

        accounts_table = Account
          .lock
          .select(:id, :member_id, :currency_id, :balance, :locked)
          .where(member_id: [@ask.member_id, @bid.member_id].uniq, currency_id: [@market.ask_unit, @market.bid_unit])
          .each_with_object({}) { |record, memo| memo["#{record.currency_id}:#{record.member_id}"] = record }

        @trade = Trade.new \
          ask:           @ask,
          ask_member_id: @ask.member_id,
          bid:           @bid,
          bid_member_id: @bid.member_id,
          price:         @price,
          volume:        @volume,
          funds:         @funds,
          market:        @market,
          trend:         _trend

        strike(@trade, @ask, accounts_table["#{@ask.ask}:#{@ask.member_id}"], accounts_table["#{@ask.bid}:#{@ask.member_id}"])
        strike(@trade, @bid, accounts_table["#{@bid.bid}:#{@bid.member_id}"], accounts_table["#{@bid.ask}:#{@bid.member_id}"])

        ([@ask, @bid] + accounts_table.values).map do |record|
          table     = record.class.arel_table
          statement = Arel::UpdateManager.new(table.engine)
          statement.table(table)
          statement.where(table[:id].eq(record.id))
          updates = record.changed_attributes.map do |(attribute, previous_value)|
            if Order === record
              value = record.public_send(attribute)
              [table[attribute], { wait: 100, done: 200, cancel: 0 }.with_indifferent_access.fetch(value, value)]
            else
              [table[attribute], record.public_send(attribute)]
            end
          end
          statement.set updates
          statement.to_sql
        end.join('; ').tap do |sql|
          Rails.logger.debug { sql }
          client = ActiveRecord::Base.connection.raw_connection
          client.query(sql)
          while client.next_result
          end
        end

        @trade.save(validate: false)
      end
    end

    def publish_trade
      AMQPQueue.publish :trade, @trade.as_json, {
        headers: {
          market:        @market.id,
          ask_member_id: @ask.member_id,
          bid_member_id: @bid.member_id
        }
      }

      [@ask, @bid].each do |order|
        next unless order.ord_type == 'limit'
        event = case order.state
          when 'cancel' then 'order_canceled'
          when 'done'   then 'order_completed'
          else 'order_updated'
        end
        EventAPI.notify ['market', order.market_id, event].join('.'), \
          Serializers::EventAPI.const_get(event.camelize).call(order)
      end
    end

    def raise_error(code, message)
      raise TradeExecutionError.new \
        ask:     @ask.attributes,
        bid:     @bid.attributes,
        price:   @price,
        volume:  @volume,
        funds:   @funds,
        code:    code,
        message: message
    end

    def strike(trade, order, outcome_account, income_account)
      outcome_value, income_value = OrderAsk === order ? [trade.volume, trade.funds] : [trade.funds, trade.volume]
      fee                         = income_value * order.fee
      real_income_value           = income_value - fee

      outcome_account.assign_attributes outcome_account.attributes_after_unlock_and_sub_funds!(outcome_value)
      income_account.assign_attributes income_account.attributes_after_plus_funds!(real_income_value)

      order.volume         -= trade.volume
      order.locked         -= outcome_value
      order.funds_received += income_value
      order.trades_count   += 1

      if order.volume.zero?
        order.state = Order::DONE

        # Unlock not used funds.
        unless order.locked.zero?
          outcome_account.assign_attributes outcome_account.attributes_after_unlock_funds!(order.locked)
        end
      elsif order.ord_type == 'market' && order.locked.zero?
        # Partially filled market order has run out it's locked funds.
        order.state = Order::CANCEL
      end
    end
  end
end
