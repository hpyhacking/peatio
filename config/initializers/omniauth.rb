Rails.application.config.middleware.use OmniAuth::Builder do
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

  if ENV['GOOGLE_OAUTH2_SIGN_IN']
    provider :google_oauth2, ENV.fetch('GOOGLE_CLIENT_ID'), ENV.fetch('GOOGLE_CLIENT_SECRET')
  end
end

OmniAuth.config.on_failure = lambda do |env|
  SessionsController.action(:failure).call(env)
end

OmniAuth.config.logger = Rails.logger
