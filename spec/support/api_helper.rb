def time_to_milliseconds(t=Time.now)
  (t.to_f*1000).to_i
end

def sign(secret_key, method, uri, params)
  req = mock('request', request_method: method.to_s.upcase, path_info: uri)
  auth = APIv2::Auth::Authenticator.new(req, params)
  APIv2::Auth::Utils.hmac_signature(secret_key, auth.payload)
end

def signed_request(method, uri, opts={})
  token = opts[:token] || create(:api_token)
  path  = uri.sub(/^\/api/, '')

  params = opts[:params] || {}
  params[:access_key] = token.access_key
  params[:tonce]      = time_to_milliseconds
  params[:signature]  = sign(token.secret_key, method, path, params)

  send method, uri, params
end

def signed_get(uri, opts={})
  signed_request :get, uri, opts
end

def signed_post(uri, opts={})
  signed_request :post, uri, opts
end

def signed_delete(uri, opts={})
  signed_request :delete, uri, opts
end
