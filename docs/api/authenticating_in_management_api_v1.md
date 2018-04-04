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
    value:     LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF3UjNPT1RQbzZvZE8wM3hXVDRNawp6TXJuM2pQS2pVdW0rVkc5dUZWODZNejVnMm1ueXdSRDc4MEY4aXVaZm41SGtROFpTUlFHYlRHNnB1dlVWWDFCClA0MWIrUW52VHFtWFhHcE9aSklzV3V2cHA4dHpZenFOejUvcTRRdUZQWDlrczdtaVV2dkNzbmo5S21Wb08yMU4KUVgyOWZUNkRJYldkUnJvWU1IOHloVmRrSjRVQnhYeHlSWmZ4VnN4UFVwckNodEgxN1JwNnQvYVRTR0VZNndQNwpKbEVCZi9Gb0djQk15OU5BOWhqZFMyMWxGcmVYeXdaUzZYdmhrN3dydGJWT2didU5EajdVeWhjS0RCaHA4c2VjCkV4TlB6d2p4ckhGTzhZaitFejBCMmZKQ1FDWW9SVG1kTzVEQS9kRTFHQmtqeXRCZjhDdGVIdExXcmZIU2g5em0KNlFJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==
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

Example:

```ruby
require 'openssl'
require 'jwt-multisig'

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
  :'backend-2.mycompany.example' => 'RS256',
  :'backend-.mycompany.example' => 'RS256'
}

jwt = JWT::Multisig.generate_jwt(payload, private_keychain, algorithms)

Kernel.puts JSON.dump(jwt) # The output will include serialized JWT.
```

The documentation for this method is available at [rubydoc.info](http://www.rubydoc.info/gems/jwt-multisig/JWT/Multisig#generate_jwt-class_method).
The source code for `jwt-multisig` is available at [GitHub](https://github.com/rubykube/jwt-multisig).
The example JWT is available at [jwt-multisig source code](https://github.com/rubykube/jwt-multisig/blob/master/lib/jwt-multisig.rb#L25).

## Step 6: Make requests to API.

```
curl -v -H "Accept: application/json" -H "Content-Type: application/json" -d "JWT" http://peatio.io/management_api/v1/deposits
```

Where `JWT` is the result from previous step (serialized JWT).
