signup = lambda { |env| 
  IdentitiesController.action(:new).call(env) 
}

failure = lambda { |env|
  SessionsController.action(:failure).call(env)
}

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :identity, fields: [:email], on_failed_registration: signup
end

OmniAuth.config.on_failure = failure
OmniAuth.config.logger = Rails.logger
