# encoding: UTF-8
# frozen_string_literal: true

Rails.configuration.x.jwt_public_key =
  if ENV['JWT_PUBLIC_KEY'].present?
    key = OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV['JWT_PUBLIC_KEY']))
    raise ArgumentError, 'JWT_PUBLIC_KEY was set to private key, however it should be public.' if key.private?
    key
  end

Rails.configuration.x.jwt_options = {
  algorithm: ENV.fetch('JWT_ALGORITHM', 'RS256'),
  verify_expiration: true,
  verify_not_before: true,
  iss: ENV['JWT_ISSUER'],
  verify_iss: ENV['JWT_ISSUER'].present?,
  verify_iat: true,
  verify_jti: true,
  aud: ENV['JWT_AUDIENCE'].to_s.split(',').reject(&:blank?),
  verify_aud: ENV['JWT_AUDIENCE'].present?,
  sub: 'session',
  verify_sub: true,
}.compact.tap do |jwt_options|
  leeway_options = {
    leeway: ENV['JWT_DEFAULT_LEEWAY'],
    iat_leeway: ENV['JWT_ISSUED_AT_LEEWAY'],
    exp_leeway: ENV['JWT_EXPIRATION_LEEWAY'],
    nbf_leeway: ENV['JWT_NOT_BEFORE_LEEWAY'],
  }.compact.transform_values!(&:to_i)

  jwt_options.merge!(leeway_options)

  # Set algorithm to 'none' if public key was not provided.
  # Since rack-jwt requires public_key for all algorithms except 'none'
  # Also using empty public key doesn't make sense unless you use 'none' algorithm.
  jwt_options[:algorithm] = 'none' if Rails.configuration.x.jwt_public_key.blank?
end
