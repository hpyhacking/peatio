module APIv2
  module Constraints
    class <<self

      def included(base)
        apply_rules!
        base.use Rack::Attack
      end

      def apply_rules!
        Rack::Attack.throttle('Authorized access', limit: 600, period: 5.minutes) do |req|
          req.env['api_v2.token'] && req.env['api_v2.token'].access_key
        end
      end

    end
  end
end
