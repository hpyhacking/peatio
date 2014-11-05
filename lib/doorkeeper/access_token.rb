# Extend Doorkeeper::AccessToken to add a new access token type:
#   urn:peatio:api:v2:token

module Doorkeeper
  class AccessToken

    def token_type
      'urn:peatio:api:v2:token'
    end

    private

    def generate_token
      member = Member.find resource_owner_id
      token  = member.api_tokens.create!
      self.token = token.to_oauth_token
    end

  end
end
