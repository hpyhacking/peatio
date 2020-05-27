# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Constraints
      class << self
        def included(base)
          rate_limit = ENV.fetch("PEATIO_RATE_LIMIT_5MIN", 6000).to_i
          apply_rules!(rate_limit)
          base.use Rack::Attack
        end

        def apply_rules!(rate_limit)
          Rack::Attack.throttle 'Limit number of calls to API', limit: rate_limit, period: 5.minutes do |req|
            req.env['api_v2.authentic_member_email']
          end
        end
      end
    end
  end
end
