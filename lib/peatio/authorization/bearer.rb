# frozen_string_literal: true

# Provides authentication functionality.
module Authorization
  module Bearer

    # Decodes and verifies JWT.
    # Returns authentic member email or raises an exception.
    #
    # @param [string] Authorization header with a Bearer token to decode
    # @return [String, Member, NilClass]
    def authenticate!(token)
      jwt_authenticator.authenticate!(token)
    end

    private

    # JWT authenticator instance. See peatio-core gem.
    #
    # @return [Peatio::Auth::JWTAuthenticator]
    def jwt_authenticator
      @jwt_authenticator ||=
        Peatio::Auth::JWTAuthenticator.new(Rails.configuration.x.jwt_public_key)
    end
  end
end
