Rails.application.config.middleware.use OmniAuth::Builder do
  provider :identity, fields: [:email], on_failed_registration: IdentitiesController.action(:new)
  
  if ENV['AUTH0_OAUTH2_SIGN_IN']
    provider :auth0,
             ENV.fetch('AUTH0_OAUTH2_CLIENT_ID'),
             ENV.fetch('AUTH0_OAUTH2_CLIENT_SECRET'),
             ENV.fetch('AUTH0_OAUTH2_DOMAIN'),
             { authorize_params: {
                 scope: ENV.fetch('AUTH0_OAUTH2_SCOPE', 'openid profile email')
               }
             }
  end
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
