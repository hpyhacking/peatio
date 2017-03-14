Rails.application.config.middleware.use OmniAuth::Builder do
  provider :identity, fields: [:email], on_failed_registration: IdentitiesController.action(:new)
end

OmniAuth.config.on_failure = lambda do |env|
  SessionsController.action(:failure).call(env)
end

OmniAuth.config.logger = Rails.logger

module OmniAuth
  module Strategies
   class Identity
     def request_phase
       redirect '/signin'
     end

     def registration_form
       redirect '/signup'
     end
   end
 end
end
