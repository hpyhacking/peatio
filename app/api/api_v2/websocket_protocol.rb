module APIv2
  class WebSocketProtocol
    def initialize(socket, channel, logger)
      @socket  = socket
      @channel = channel
      @logger  = logger
    end

    def challenge
      @challenge = SecureRandom.urlsafe_base64(40)
      send :challenge, @challenge
    end

    def handle(msg)
      @logger.debug(msg)
      msg = JSON.parse(msg)
      key = msg.keys.first

      return unless key.casecmp('auth')

      token   = msg['jwt']
      service = APIv2::Auth::JWTAuthenticator.new(token)
      member  = service.authenticate(return: :member)

      if member
        subscribe_orders
        subscribe_trades(member)
        send :success, message: 'Authenticated.'
      else
        send :error, message: 'Authentication failed.'
      end

    rescue => e
      @logger.error 'Error while handling message.'
      report_exception(e)
    end

  private

    def send(method, data)
      payload = JSON.dump(method => data)
      @logger.debug payload
      @socket.send payload
    end

    def subscribe_orders
      x = @channel.send *AMQPConfig.exchange(:orderbook)
      q = @channel.queue '', auto_delete: true
      q.bind(x).subscribe do |metadata, payload|
        begin
          payload = JSON.parse payload
          send :orderbook, payload
        rescue => e
          Rails.logger.error 'Error on receiving orders.'
          report_exception(e)
        end
      end
    end

    def subscribe_trades(member)
      x = @channel.send *AMQPConfig.exchange(:trade)
      q = @channel.queue '', auto_delete: true
      q.bind(x, arguments: {'ask_member_id' => member.id, 'bid_member_id' => member.id, 'x-match' => 'any'})
      q.subscribe(ack: true) do |metadata, payload|
        begin
          payload = JSON.parse payload
          trade   = Trade.find payload['id']

          send :trade, serialize_trade(trade, member, metadata)
        rescue => e
          Rails.logger.error 'Error on receiving trades.'
          report_exception(e)
        ensure
          metadata.ack
        end
      end
    end

    def serialize_trade(trade, member, metadata)
      side = trade_side(member, metadata.headers)
      hash = ::APIv2::Entities::Trade.represent(trade, side: side).serializable_hash

      if %i[both ask].include?(side)
        hash[:ask] = ::APIv2::Entities::Order.represent trade.ask
      end

      if %i[both bid].include?(side)
        hash[:bid] = ::APIv2::Entities::Order.represent trade.bid
      end

      hash
    end

    def trade_side(member, headers)
      if headers['ask_member_id'] == headers['bid_member_id']
        :both
      elsif headers['ask_member_id'] == member.id
        :ask
      else
        :bid
      end
    end
  end
end
