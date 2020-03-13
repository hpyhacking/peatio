# Peatio REST API

Peatio REST API allows to access market data and manage trades using the custom-written software. The end goal is to allow users to create trading platforms on their own to create highly customised and advanced trading strategies.

## General API Information

### HTTP Return Codes

- HTTP 4XX return codes are used for malformed requests; the issue is on the sender's side.
- HTTP 403 return code is used when the WAF Limit (Web Application Firewall) has been violated.
- HTTP 429 return code is used when breaking a request rate limit.
- HTTP 5XX return codes are used for internal errors; the issue is on deployment side. It is important to NOT treat this as a failure operation; the execution status is UNKNOWN and could have been a success.

### General Information on Endpoints

- All endpoints return either a JSON object or array.
- All time and timestamp related fields are in seconds.
  
### Endpoint security types

REST endpoints fall into two types the difference between the two being if the request is public, or requires authentication. In order to access the parts of the API which require authentication, you can use cookies or generate an API key and an API secret.

#### List of all user API endpoints you can find here ([user_api_docs](https://github.com/openware/peatio/blob/master/docs/api/peatio_user_api_v2.md))

#### Prerequisites

- install [httpie](https://httpie.org/doc#installation)
- install [curl](https://www.tecmint.com/install-curl-in-linux/)

## Public Endpoints Examples

Get list of avaliable currencies:

Example with httpie:

```bash
http GET https://your.domain/api/v2/peatio/public/markets
```

Expected response:

```json
[
  {
      "amount_precision": 5,
      "base_unit": "eth",
      "id": "ethusdt",
      "max_price": "1000.0",
      "min_amount": "0.00001",
      "min_price": "0.01",
      "name": "ETH/USDT",
      "price_precision": 2,
      "quote_unit": "usdt",
      "state": "enabled"
  },
  {
      "amount_precision": 6,
      "base_unit": "btc",
      "id": "btcusdt",
      "max_price": "12000.0",
      "min_amount": "0.0001",
      "min_price": "5000.0",
      "name": "BTC/USDT",
      "price_precision": 4,
      "quote_unit": "usdt",
      "state": "enabled"
  }
]
```

Example with curl:

```bash
curl -X GET https://your.domain/api/v2/peatio/public/markets
```

Expected response:

```bash
[
  {
      "amount_precision": 5,
      "base_unit": "eth",
      "id": "ethusdt",
      "max_price": "1000.0",
      "min_amount": "0.00001",
      "min_price": "0.01",
      "name": "ETH/USDT",
      "price_precision": 2,
      "quote_unit": "usdt",
      "state": "enabled"
  },
  {
      "amount_precision": 6,
      "base_unit": "btc",
      "id": "btcusdt",
      "max_price": "12000.0",
      "min_amount": "0.0001",
      "min_price": "5000.0",
      "name": "BTC/USDT",
      "price_precision": 4,
      "quote_unit": "usdt",
      "state": "enabled"
  }
]
```

## Authentication

For get access to private endpoints you can use cookies or generate API keys via UI (highly recommended) or API.

### Authentication with cookies (more for test purposes)

1. Create and save session cookies using httpie

   ```bash
   http --session barong_session https://your.domain/api/v2/barong/identity/sessions \
     email=your@email.com password=changeme
   ```

2. Call private endpoint with created session

   ```bash
   http --session barong_session https://your.domain.com/api/v2/peatio/account/balances
   ```

   Expected response:

   ```bash
   [
       {
           "balance": "1.4995",
           "currency": "eth",
           "locked": "0.0"
       },
       {
           "balance": "99.0",
           "currency": "usd",
           "locked": "0.0"
       }
   ]
   ```

### Authentication with API keys

#### How to create API key?

1. Using UI

   1. Enable 2FA
   2. Find API keys section (often located on profile page).
   3. Create your API key and securely save API Key and Secret

2. Using API (use this option in case your frontend doesn't support API keys feature)

   1. Login into your account using httpie

      ```bash
      http --session barong_session https://your.domain/api/v2/barong/identity/sessions \
        email=your@email.com password=changeme otp_code=000000
      ```

   2. Create your API key

      ```bash
      http --session barong_session https://your.domain.com/api/v2/barong/resource/api_keys \
        algorithm=HS256 totp_code=681757
      ```

      Expected response:

      ```ruby
      {
          "algorithm": "HS256",
          "created_at": "2019-12-23T12:22:15Z",
          "kid": "61d025b8573501c2", # API Key
          "scope": [],
          "secret": {
              "auth": null,
              "data": {
                  "value": "2d0b4979c7fe6986daa8e21d1dc0644f" # Secret
              },
              "lease_duration": 2764800,
              "lease_id": "",
              "metadata": null,
              "renewable": false,
              "warnings": null,
              "wrap_info": null
          },
          "state": "active",
          "updated_at": "2019-12-23T12:22:15Z"
      }
      ```

   3. Securely save API Key and Secret

#### How to use API key?

Before calling private endpoint you will need to generate three headers:

`X-Auth-Apikey` - API key (from previous step)

`X-Auth-Nonce` - A nonce is an arbitrary number that can be used just once. In our environment you *MUST* use a millisecond timestamp in UTC time. Read more about it [here](https://en.wikipedia.org/wiki/Cryptographic_nonce).

```bash
date +%s%3N
1584087661035
```

`X-Auth-Signature` - HMAC-SHA256 signature calculated using concatenation of X-Auth-Nonce and X-Auth-Apikey

```ruby
require 'openssl'

nonce = '1584087661035'
api_key = 'changeme' # API Key from 'How to create API key section ?'
secret = 'changeme' # Secret from 'How to create API key section ?'
OpenSSL::HMAC.hexdigest("SHA256", secret, nonce + api_key)
# => "6cc108cb3427b655ccf0870fc7fa807ef3756506d4db3f3c93f8d4cd8ef0e611" 
```

```bash
curl -X GET https://your.domain.com/api/v2/peatio/account/balances \
-H "X-Auth-Apikey: changeme" \
-H "X-Auth-Nonce: changeme" \
-H "X-Auth-Signature: changeme"
```

Expected response:

```bash
[
    {
        "balance": "1.4995",
        "currency": "eth",
        "locked": "0.0"
    }
]
```

Expected response:

```bash
curl -X GET https://your.domain.com/api/v2/peatio/market/orders \
-H "X-Auth-Apikey: changeme" \
-H "X-Auth-Nonce: changeme" \
-H "X-Auth-Signature: changeme"
```

   ```bash
[
    {
        "avg_price": "168.0",
        "created_at": "2020-01-28T15:14:02+01:00",
        "executed_volume": "0.1",
        "id": 6291918,
        "market": "ethusd",
        "ord_type": "limit",
        "origin_volume": "0.1",
        "price": "168.0",
        "remaining_volume": "0.0",
        "side": "buy",
        "state": "done",
        "trades_count": 1,
        "updated_at": "2020-03-12T09:17:32+01:00"
    }
]
```

## Step By step guide from authentication to create | cancel order with API keys

1. Generate API keys (see Authentication with API keys section)

2. Create order

   ```bash
   http POST https://your.domain.com/api/v2/peatio/market/orders \
   "X-Auth-Apikey: changeme" \
   "X-Auth-Nonce: changeme" \
   "X-Auth-Signature: changeme" \
   market=ethusd side=buy volume=31 ord_type=limit price=160.82
   ```

   Expected response:

   ```bash
   {
    "avg_price": "0.0",
    "created_at": "2020-03-12T17:01:56+01:00",
    "executed_volume": "0.0",
    "id": 10440269,
    "market": "ethusd",
    "ord_type": "limit",
    "origin_volume": "31.0",
    "price": "160.82",
    "remaining_volume": "31.0",
    "side": "buy",
    "state": "pending",
    "trades_count": 0,
    "updated_at": "2020-03-12T17:01:56+01:00"
    }
   ```

3. Check trade history

   ```bash
   http POST https://your.domain.com/api/v2/peatio/market/trades \
   "X-Auth-Apikey: changeme" \
   "X-Auth-Nonce: changeme" \
   "X-Auth-Signature: changeme" \
   ```

   Expected response:

   ```bash
   {
     "amount": "5.0",
     "created_at": "2020-03-12T17:01:56+01:00",
     "fee": "0.002",
     "fee_amount": "0.01",
     "fee_currency": "eth",
     "id": 1834499,
     "market": "ethusd",
     "order_id": 10440269,
     "price": "160.82",
     "side": "buy",
     "taker_type": "buy",
     "total": "804.1"
   }
   ```

4. Check active orders

   ```bash
   curl -X GET https://your.domain.com/api/v2/peatio/market/orders\?state\=wait \
   -H "X-Auth-Apikey: changeme" \
   -H "X-Auth-Nonce: changeme" \
   -H "X-Auth-Signature: changeme"
   ```

   Expected response:

   ```bash
   [
    {
        "avg_price": "160.82",
        "created_at": "2020-03-12T17:01:56+01:00",
        "executed_volume": "26.35649",
        "id": 10440269,
        "market": "ethusd",
        "ord_type": "limit",
        "origin_volume": "31.0",
        "price": "160.82",
        "remaining_volume": "4.64351",
        "side": "buy",
        "state": "wait",
        "trades_count": 6,
        "updated_at": "2020-03-12T17:01:56+01:00"
    }
   ]
   ```
  
5. Cancel active order

   ```bash
   curl -X GET https://your.domain.com/api/v2/peatio/market/orders/10440269/cancel \
   -H "X-Auth-Apikey: changeme" \
   -H "X-Auth-Nonce: changeme" \
   -H "X-Auth-Signature: changeme"
   ```

   Expected response

   ```bash
   {
    "avg_price": "160.82",
    "created_at": "2020-03-12T17:01:56+01:00",
    "executed_volume": "26.35649",
    "id": 10440269,
    "market": "ethusd",
    "ord_type": "limit",
    "origin_volume": "31.0",
    "price": "160.82",
    "remaining_volume": "4.64351",
    "side": "buy",
    "state": "wait",
    "trades_count": 6,
    "updated_at": "2020-03-12T17:01:56+01:00"
   }
   ```
