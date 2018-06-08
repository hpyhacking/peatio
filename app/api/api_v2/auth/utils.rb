# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Auth
    module Utils
      class << self
        def cache
          # Simply use rack-attack cache wrapper
          @cache ||= Rack::Attack::Cache.new
        end

        def jwt_public_key
          Rails.configuration.x.jwt_public_key
        end
      end
    end
  end
end
