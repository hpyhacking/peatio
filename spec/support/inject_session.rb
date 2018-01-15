require 'rack_session_access/capybara'

module InjectSession
  def inject_session(hash)
    page.set_rack_session(hash)
  end
end

RSpec.configure do |config|
  config.include InjectSession, type: :feature
end
