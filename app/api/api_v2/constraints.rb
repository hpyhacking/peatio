# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Constraints
    class << self
      def included(base)
        apply_rules!
        base.use Rack::Attack
      end

      def apply_rules!
        Rack::Attack.throttle 'Limit number of calls to API', limit: 6000, period: 5.minutes do |req|
          req.env['api_v2.authentic_member_email']
        end
      end
    end
  end
end
