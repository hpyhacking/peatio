def api_request(method, url, options = {})
  headers = options.fetch(:headers, {})
  params  = options.fetch(:params, {})
  options[:token].tap { |t| headers['Authorization'] = 'Bearer ' + t if t }
  send(method, url, params, headers)
end

def api_get(*args)
  api_request(:get, *args)
end

def api_post(*args)
  api_request(:post, *args)
end

#
# Generates valid JWT for member, allows to pass additional payload.
#
def jwt_for(member, payload = { x: 'x', y: 'y', z: 'z' })
  jwt_build(payload.merge(email: member.email))
end

#
# Generates valid JWT. Accepts payload as argument. Add fields required for JWT to be valid.
#
def jwt_build(payload)
  jwt_encode payload.reverse_merge \
    iat: Time.now.to_i,
    exp: 20.minutes.from_now.to_i,
    jti: SecureRandom.uuid,
    sub: 'session',
    iss: 'peatio',
    aud: ['peatio']
end

#
# Generates JWT token based on payload. Doesn't add any extra fields to payload.
#
def jwt_encode(payload)
  JWT.encode(payload, APIv2::Auth::Utils.jwt_shared_secret_key, 'RS256')
end
