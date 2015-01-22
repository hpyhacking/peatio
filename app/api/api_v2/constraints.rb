module APIv2
  module Constraints
    class <<self

      def included(base)
        apply_rules!
        base.use Rack::Attack
      end

      def apply_rules!
        Rack::Attack.blacklist('block api access from other ip if trusted ip set ') do |req|
          req.env['api_v2.token'] && !req.env['api_v2.token'].allow_ip?(req.ip)
        end

        Rack::Attack.throttle('Authorized access', limit: 6000, period: 5.minutes) do |req|
          req.env['api_v2.token'] && req.env['api_v2.token'].access_key
        end
      end

    end
  end
end
