module APIv2
  class WebSocketProtocol

    def initialize(socket, channel, logger)
      @socket = socket
      @channel = channel #FIXME: amqp should not be mixed into this class
      @logger = logger
    end

    def challenge
      @challenge = SecureRandom.urlsafe_base64(40)
      send :challenge, @challenge
    end

    def handle(message)
      @logger.debug message

      message = JSON.parse(message)
      key     = message.keys.first
      data    = message[key]

      case key.downcase
      when 'auth'
        access_key = data['access_key']
        token = APIToken.where(access_key: access_key).includes(:member).first
        result = verify_answer data['answer'], token

        if result
          subscribe_orders
          subscribe_trades token.member
          send :success, {message: "Authenticated."}
        else
          send :error, {message: "Authentication failed."}
        end
      else
      end
    rescue
      @logger.error "Error on handling message: #{$!}"
      @logger.error $!.backtrace.join("\n")
    end

    private

    def send(method, data)
      payload = JSON.dump({method => data})
      @logger.debug payload
      @socket.send payload
    end

    def verify_answer(answer, token)
      str = "#{token.access_key}#{@challenge}"
      answer == OpenSSL::HMAC.hexdigest('SHA256', token.secret_key, str)
    end

    def subscribe_orders
      x = @channel.send *AMQPConfig.exchange(:orderbook)
      q = @channel.queue '', auto_delete: true
      q.bind(x).subscribe do |metadata, payload|
        begin
          payload = JSON.parse payload
          send :orderbook, payload
        rescue
          @logger.error "Error on receiving orders: #{$!}"
          @logger.error $!.backtrace.join("\n")
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
        rescue
          @logger.error "Error on receiving trades: #{$!}"
          @logger.error $!.backtrace.join("\n")
        ensure
          metadata.ack
        end
      end
    end

    def serialize_trade(trade, member, metadata)
      side = trade_side(member, metadata.headers)
      hash = ::APIv2::Entities::Trade.represent(trade, side: side).serializable_hash

      if [:both, :ask].include?(side)
        hash[:ask] = ::APIv2::Entities::Order.represent trade.ask
      end

      if [:both, :bid].include?(side)
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
