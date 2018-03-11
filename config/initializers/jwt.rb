unless ENV['JWT_PUBLIC_KEY'].blank?
  unless APIv2::Auth::Utils.jwt_public_key.public?
    raise ArgumentError, 'JWT_PUBLIC_KEY was set to private RSA key, however it should be public.'
  end
end
