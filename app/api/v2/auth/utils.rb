# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Auth
      module Utils
        class << self
          def cache
            # Simply use rack-attack cache wrapper
            @cache ||= Rack::Attack::Cache.new
          end
        end
      end
    end
  end
end
