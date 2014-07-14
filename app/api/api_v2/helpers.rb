module APIv2
  module Helpers

    def authenticate!
      current_user or raise AuthorizationError
    end

    def redis
      @r ||= Redis.new url: ENV["REDIS_URL"], db: 1
    end

    def current_user
      @current_user ||= current_token.try(:member)
    end

    def current_token
      @current_token ||= env['api_v2.token']
    end

    def current_market
      @current_market ||= Market.find params[:market]
    end

    def time_to
      params[:timestamp].present? ? Time.at(params[:timestamp]) : nil
    end

    def create_order(attrs)
      klass = attrs[:side] == 'sell' ? OrderAsk : OrderBid

      order = klass.new(
        source:        'APIv2',
        state:         ::Order::WAIT,
        member_id:     current_user.id,
        ask:           current_market.target_unit,
        bid:           current_market.price_unit,
        currency:      current_market.id,
        ord_type:      attrs[:ord_type] || 'limit',
        price:         attrs[:price],
        volume:        attrs[:volume],
        origin_volume: attrs[:volume]
      )
      Ordering.new(order).submit

      order
    rescue
      Rails.logger.info "Failed to create order: #{$!}"
      Rails.logger.debug order.inspect
      Rails.logger.debug $!.backtrace.join("\n")
      raise CreateOrderError, $!
    end

  end
end
