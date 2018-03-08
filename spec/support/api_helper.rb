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

def jwt_for(member, payload = { x: 'x', y: 'y', z: 'z' })
  jwt_encode(payload.merge(email: member.email))
end

def jwt_encode(payload)
  JWT.encode(payload, APIv2::Auth::Utils.jwt_shared_secret_key, 'RS256')
end
