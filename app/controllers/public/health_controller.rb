# encoding: UTF-8
# frozen_string_literal: true

module Public
  class HealthController < ActionController::Base
    def alive
      render_health_status Services::HealthChecker.alive?
    end

    def ready
      render_health_status Services::HealthChecker.ready?
    end

    private

    def render_health_status(health)
      head health ? 200 : 503
    end
  end
end
