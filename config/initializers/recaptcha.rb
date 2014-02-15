Recaptcha.configure do |config|
  config.public_key  = ENV['RECAPTCHA_PUBLIC_KEY']
  config.private_key = ENV['RECAPTCHA_PRIVATE_KEY']
end

module Recaptcha
  module Verify
    def verify_recaptcha_with_development(*options)
      if Rails.env.production?
        verify_recaptcha_without_development(*options)
      else
        if self.params[:skip] == 'skip'
          true
        else
          verify_recaptcha_without_development(*options)
        end
      end
    end

    alias_method_chain :verify_recaptcha, :development
  end
end
