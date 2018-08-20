# Authenticating in Management API v1

## Step 1: Generate keypair.

`ruby -e "require 'openssl'; require 'base64'; OpenSSL::PKey::RSA.generate(2048).tap { |p| puts '', 'PRIVATE RSA KEY (URL-safe Base64 encoded, PEM):', '', Base64.urlsafe_encode64(p.to_pem), '', 'PUBLIC RSA KEY (URL-safe Base64 encoded, PEM):', '', Base64.urlsafe_encode64(p.public_key.to_pem) }"`

## Step 2: Include public key in the `config/management_api_v1.yml` at Peatio.

You should give the ID to the key and put it in variable called `keychain`.

The variable `keychain` in `config/management_api_v1.yml` should look like:

```yml
keychain:
  backend-1.mycompany.example:
    algorithm: RS256
    value: 'BACKEND_1_PUBLIC_KEY_IN_PEM_FORMAT_BASE64_URLSAFE_ENCODED'  
  backend-2.mycompany.example:
    algorithm: RS256
    value: 'BACKEND_2_PUBLIC_KEY_IN_PEM_FORMAT_BASE64_URLSAFE_ENCODED'
```

The `value` is public key from URL-safe Base64 encoded PEM from the first step.
The `algorithm` is signature algorithm you prefer.

## Step 3: Configure JWT claims.

You can customize JWT verification options using variable `jwt` in `config/management_api_v1.yml`:

```yml
jwt:
  verify_jti: true
  verify_aud: true
  exp_leeway: 180
```

The documentation is available at [jwt repository](https://github.com/jwt/ruby-jwt#support-for-reserved-claim-names).

## Step 4: Configure security scopes.

The `config/management_api_v1.yml` already includes good docs for this step. You can find it at the bottom near variable `scopes`.

## Step 5: Configure JWT provider and deliver private key.

The JWT provider can use Ruby Gem `jwt-multisig` for generating JWT with multiple signatures.

You should store private keys (ID, value, algorithm) somewhere in your application.

To generate JWS use the `JWT::Multisig.generate_jwt(payload, private_keychain, algorithms)`.

In `private_keychain` you need to put private key from URL-safe Base64 encoded PEM from the first step.

The output from this example with serialized JWT will be save in data.json.

Example:

```ruby
require 'openssl'
require 'jwt-multisig'
require 'base64'
require 'json'

payload = { 
  exp:  1922830281, # Put here all the JWT claims.
  data: { foo: 'bar', baz: 'qux' } # Put here all the data your API action expects.
}

# You can choose what signatures the JWT should include.
private_keychain = {
  :'backend-1.mycompany.example' => OpenSSL::PKey.read(Base64.urlsafe_decode64('BACKEND_1_PRIVATE_KEY_IN_PEM_FORMAT_BASE64_URLSAFE_ENCODED')),
  :'backend-2.mycompany.example' => OpenSSL::PKey.read(Base64.urlsafe_decode64('BACKEND_2_PRIVATE_KEY_IN_PEM_FORMAT_BASE64_URLSAFE_ENCODED'))
}

algorithms = {
  :'backend-1.mycompany.example' => 'RS256',
  :'backend-2.mycompany.example' => 'RS256'
}

jwt = JWT::Multisig.generate_jwt(payload, private_keychain, algorithms)

Kernel.puts JSON.dump(jwt) # The output will include serialized JWT.

# Save your JWT in data.json
File.open('./data.json','w') do |f|
  f.write(jwt.to_json)
end
```

The documentation for this method is available at [rubydoc.info](http://www.rubydoc.info/gems/jwt-multisig/JWT/Multisig#generate_jwt-class_method).
The source code for `jwt-multisig` is available at [GitHub](https://github.com/rubykube/jwt-multisig).
The example JWT is available at [jwt-multisig source code](https://github.com/rubykube/jwt-multisig/blob/master/lib/jwt-multisig.rb#L25).

## Step 6: Make requests to API.

With next example you can make request with ruby Faraday client library or make request with curl. This request will return empty array if you don't have any deposits on the platform.

Example:

```ruby
require 'json'
require 'faraday'
require 'faraday_middleware'

# Read and save your JWT from data.json
data = File.read('./data.json')

# Create HTTP request with ruby Faraday client library 
module Faraday
  class Connection
    alias original_run_request run_request
    def run_request(method, url, body, headers, &block)
      original_run_request(method, url, body, headers, &block).tap do |response|
        response.env.instance_variable_set :@request_body, body if body
      end
    end
  end
end

def http_client
  Faraday.new(url: @root_api_url) do |conn|
    conn.request :json
    conn.response :json
    conn.adapter Faraday.default_adapter
  end
end

# The output will include request response
Kernel.puts http_client
  .public_send(:post,'http://localhost:3000/management_api/v1/deposits', data)
  .body
```

Make request with curl.

```
curl -v -H "Accept: application/json" -H "Content-Type: application/json" -d @jwt.json http://localhost:3000/management_api/v1/deposits
```
