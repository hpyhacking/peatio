def sign_params(secret_key, params)
  auth = APIv2::Authenticator.new(nil, params)
  APIv2::Authenticator.hmac_signature(secret_key, auth.payload)
end

def signed_request(method, uri, opts={})
  token = opts[:token] || create(:api_token)

  params = opts[:params] || {}
  params[:access_key] = token.access_key
  params[:tonce]      = (Time.now.to_f*1000).to_i
  params[:signature]  = sign_params(token.secret_key, params)

  send method, uri, params
end

def signed_get(uri, opts={})
  signed_request :get, uri, opts
end
