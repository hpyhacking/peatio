Recaptcha.configure do |config|
  config.public_key  = ENV['RECAPTCHA_PUBLIC_KEY']
  config.private_key = ENV['RECAPTCHA_PRIVATE_KEY']
end

module Recaptcha
  module Verify
    def verify_recaptcha_with_development(options = {})
      options[:attribute] ||= 'recaptcha'
      return true if Rails.env.test?

      if Rails.env.production?
        verify_recaptcha_without_development(options)
      else
        if self.params[:recaptcha_response_field] == 'skip'
          true
        else
          verify_recaptcha_without_development(options)
        end
      end
    end

    alias_method_chain :verify_recaptcha, :development
  end
end
