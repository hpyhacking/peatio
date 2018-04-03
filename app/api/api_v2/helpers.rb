module APIv2
  module Helpers
    def authenticate!
      current_user or raise AuthorizationError
    end

    def email_must_be_verified!
      if current_user.level? && !current_user.level.in?(%w[ email_verified phone_verified identity_verified ])
        raise Grape::Exceptions::Base.new(text: 'Please, verify your E-Mail address.', status: 401)
      end
    end

    def phone_must_be_verified!
      if current_user.level? && !current_user.level.in?(%w[ email_verified phone_verified ])
        raise Grape::Exceptions::Base.new(text: 'Please, verify your phone.', status: 401)
      end
    end

    def identity_must_be_verified!
      if current_user.level? && !current_user.level.identity_verified?
        raise Grape::Exceptions::Base.new(text: 'Please, verify your identity.', status: 401)
      end
    end

    def redis
      @r ||= KlineDB.redis
    end

    def current_user
      # JWT authentication provides member email.
      if env.key?('api_v2.authentic_member_email')
        Member.find_by_email(env['api_v2.authentic_member_email'])
      end
    end

    def current_market
      @current_market ||= Market.find params[:market]
    end

    def time_to
      params[:timestamp].present? ? Time.at(params[:timestamp]) : nil
    end

    def build_order(attrs)
      klass = attrs[:side] == 'sell' ? OrderAsk : OrderBid

      order = klass.new(
        source:        'APIv2',
        state:         ::Order::WAIT,
        member_id:     current_user.id,
        ask:           Currency.find_by!(code: current_market.base_unit).id,
        bid:           Currency.find_by!(code: current_market.quote_unit).id,
        market_id:     current_market.id,
        ord_type:      attrs[:ord_type] || 'limit',
        price:         attrs[:price],
        volume:        attrs[:volume],
        origin_volume: attrs[:volume]
      )
    end

    def create_order(attrs)
      order = build_order attrs
      Ordering.new(order).submit
      order
    rescue
      Rails.logger.info "Failed to create order: #{$!}"
      Rails.logger.debug order.inspect
      Rails.logger.debug $!.backtrace.join("\n")
      raise CreateOrderError, $!
    end

    def create_orders(multi_attrs)
      orders = multi_attrs.map {|attrs| build_order attrs }
      Ordering.new(orders).submit
      orders
    rescue
      Rails.logger.info "Failed to create order: #{$!}"
      Rails.logger.debug $!.backtrace.join("\n")
      raise CreateOrderError, $!
    end

    def order_param
      params[:order_by].downcase == 'asc' ? 'id asc' : 'id desc'
    end

    def format_ticker(ticker)
      { at: ticker[:at],
        ticker: {
          buy: ticker[:buy],
          sell: ticker[:sell],
          low: ticker[:low],
          high: ticker[:high],
          last: ticker[:last],
          vol: ticker[:volume]
        }
      }
    end

    def get_k_json
      key = "peatio:#{params[:market]}:k:#{params[:period]}"

      if params[:timestamp]
        ts = JSON.parse(redis.lindex(key, 0)).first
        offset = (params[:timestamp] - ts) / 60 / params[:period]
        offset = 0 if offset < 0

        JSON.parse('[%s]' % redis.lrange(key, offset, offset + params[:limit] - 1).join(','))
      else
        length = redis.llen(key)
        offset = [length - params[:limit], 0].max
        JSON.parse('[%s]' % redis.lrange(key, offset, -1).join(','))
      end
    end
  end
end
