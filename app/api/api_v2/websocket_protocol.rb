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
            subscribe_trades @member
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

    def subscribe_trades(member)
      x = @channel.send *AMQPConfig.exchange(:trade)
      q = @channel.queue '', auto_delete: true
      q.bind(x, arguments: {'ask_member_id' => member.id, 'bid_member_id' => member.id, 'x-match' => 'any'})
      q.subscribe(ack: true) do |metadata, payload|
        defer -> {
          payload = JSON.parse payload
          trade   = Trade.find payload['id']
          serialize_trade trade, member, metadata
        }, ->(trade) {
          send :trade, trade
          metadata.ack
        }, ->(error) {
          metadata.ack
        }
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
