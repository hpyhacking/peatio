# frozen_string_literal: true

# Authentication test helpers
module AuthTestHelpers
  AUTH_HEADER_NAME = 'Authorization'.freeze

  def inject_authorization!(member)
    @request.env['jwt.payload'] =
      { email: member.email, uid: member.uid,
        role: member.role, state: member.state, level: member.level }
  end

  def eject_authorization!
    @request.env['jwt.payload'] = nil
  end
end

RSpec.configure do |config|
  config.include AuthTestHelpers, type: :controller
end
