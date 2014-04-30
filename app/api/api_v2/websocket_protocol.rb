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
      key = message.keys.first
      data = message[key]
      case key.downcase
      when 'auth'
        EM.defer -> {
          access_key = data['access_key']
          token = APIToken.where(access_key: access_key).includes(:member).first
          result = verify_answer data['answer'], token
          [result, token, token.member]
        }, ->((result, token, member)) {
          if result
            @token  = token
            @member = member
            subscribe_trade_topics @member
            send :success, {message: "Authenticated."}
          else
            send :error, {message: "Authentication failed."}
          end
        }
      else
      end
    end

    private

    def send(method, data)
      payload = JSON.dump({method => data})
      @socket.send payload
    end

    def verify_answer(answer, token)
      str = "#{token.access_key}#{@challenge}"
      answer == OpenSSL::HMAC.hexdigest('SHA256', token.secret_key, str)
    end

    def subscribe_trade_topics(member)
      subscribe_trade member, :ask
      subscribe_trade member, :bid
    end

    def subscribe_trade(member, side)
      x = @channel.send *AMQPConfig.exchange(:octopus)
      q = @channel.queue '', auto_delete: true
      q.bind(x, routing_key: trade_topic(side, member))
      q.subscribe(ack: true) do |metadata, payload|
        EM.defer -> {
          payload = JSON.parse payload
          if trade = Trade.find_by_id(payload['id'])
            ::APIv2::Entities::Trade.represent(trade, include_order: side, side: side).to_json
          end
        }, ->(json) {
          send :trade, json if json.present?
          metadata.ack
        }
      end
    end

    def trade_topic(side, member)
      side == :ask ? "trade.*.#{member.id}.*" : "trade.*.*.#{member.id}"
    end

  end
end
