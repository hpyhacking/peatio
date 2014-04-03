module APIv2
  module Auth

    extend self

    def urlsafe_string_40
      # 30 is picked so generated string length is 40
      SecureRandom.urlsafe_base64(30).tr('_-', 'xx')
    end

    alias :generate_access_key :urlsafe_string_40
    alias :generate_secret_key :urlsafe_string_40

  end
end
