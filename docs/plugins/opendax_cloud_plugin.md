##  Opendax Cloud plugin

This service is used in Openfinex microservice to generate wallets, sign and broadcast transactions

### Authorization
You should have two required env variables in peatio to make this plugin work
- `PLATFORM_ID` - will be saved automatically on platform creation API call
- `PEATIO_JWT_PRIVATE_KEY` - peatio private key

### Settings configuration
Here the most important configuration for wallet configurations

Deposit/Hot wallet

```json
gateway: field set as `opendax_cloud`
settings:
  uri: a link to openfinex (e.g. "https://#{domain_name}/api/v2/opx/peatio")
```

#### Implemented functions are
1. **Create address**
For address creating you need to be sure that your deposit wallet has right configuration:
- `blockchain_key` should be some  blockchain with right explorer_address, explorer_transaction which you use for your currency configuration too
- `gateway` field set as `opendax_cloud`
- in wallet settings you have:
  - `uri` should be a link to openfinex cloud, default is `https://#{domain_name}/api/v2/opx/peatio`

2. **Create transaction**
3. **Load balance**
Be sure you have correct address in deposit/hot wallet configuration

4. **Trigger webhook event**

This method requires `OPENFINEX_CLOUD_PUBLIC_KEY` env variable which will be used to decode request body from JWT (algorithm 'ES256') and return a list of transactions.
