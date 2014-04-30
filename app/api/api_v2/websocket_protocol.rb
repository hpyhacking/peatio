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
        defer -> {
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
        defer -> {
          payload = JSON.parse payload
          trade = Trade.where("#{side}_member_id" => member.id, "id" => payload['id']).first
          trade && ::APIv2::Entities::Trade.represent(trade, include_order: side, side: side).serializable_hash
        }, ->(trade) {
          send :trade, trade
          metadata.ack
        }, ->(error) {
          metadata.ack
        }
      end
    end

    def trade_topic(side, member)
      side == :ask ? "trade.*.#{member.id}.*" : "trade.*.*.#{member.id}"
    end

    def defer(job, callback, errback=nil)
      EM.defer -> {
        begin
          job.call
        rescue
          @logger.error "Error on handling message: #{$!}"
          @logger.error $!.backtrace[0,20].join("\n")
          $!
        end
      }, ->(result) {
        if result.is_a?(Exception)
          errback.call(result) if errback
        else
          callback.call(result)
        end
      }
    end

  end
end
