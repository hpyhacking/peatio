# frozen_string_literal: true

# Authentication test helpers
module AuthTestHelpers
  AUTH_HEADER_NAME = 'Authorization'.freeze

  def auth_get(method, params, token)
    request.headers[AUTH_HEADER_NAME] = "Bearer #{token}"
    get(method, params)
  end

  def inject_authorization!(m)
    @request.headers[AUTH_HEADER_NAME] = "Bearer #{jwt_for(m)}"
  end

  def eject_authorization!
    @request.headers[AUTH_HEADER_NAME] = nil
  end
end

RSpec.configure do |config|
  config.include AuthTestHelpers, type: :controller
end
