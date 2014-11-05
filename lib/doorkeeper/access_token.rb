# Extend Doorkeeper::AccessToken to add a new access token type:
#   urn:peatio:api:v2:token

module Doorkeeper
  class AccessToken

    def token_type
      'urn:peatio:api:v2:token'
    end

  end
end
