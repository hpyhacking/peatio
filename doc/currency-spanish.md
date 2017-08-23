Esta es una recopilación de la documentación encontrada y que me ha funcionado para mi fork de [Peatio](https://github.com/ShadowMyst/peatio), basada principalmente en el gist de [Brossi](https://gist.github.com/brossi/175f60bd1dc4f99f9373) que despues de usarla he actualizado.

#Daemon de la criptomoneda
Para agregar una nueva moneda se tiene que agregar en la configuración del daemon `{coin}.conf` de la criptomoneda el comando `-walletnotify` para que lo reconozca RabbitMQ

```
# Notify when receiving coins
walletnotify=/usr/local/sbin/rabbitmqadmin publish routing_key=peatio.deposit.coin payload='{"txid":"%s", "channel_key":"COIN_NAME_SINGULAR"}'
```
Actualizar los archivos de Peatio necesarios para que se liste la nueva divisa.

### config/currencies.yml
```
 - id: [uniq_number]
   key: creativecoin
   symbol: "CREA"
   coin: true
   quick_withdraw_max: 0
   rpc: http://username:password@host:port
   blockchain: https://dominiodeblockchain/tx/#{txid}
   address_url: https://dominioparadireccion/address/#{address}
   assets:
     accounts:
       -
         address: CTxsnfCPVXwESqNa58AY4oA31m3z58BYPQ
```
### config/deposit_channels.yml
```
- id: [unic_number]
  key: creativecoin
  currency: crea
  sort_order: 1
  min_confirm: 1
  max_confirm: 3
```
### config/markets.yml
```
- id: ltccny
  code: [unic_number]
  #name: LTC/CNY      # default name
  base_unit: ltc
  quote_unit: cny
  #price_group_fixed: 1 # aggregate price levels in orderbook
  bid: {fee: 0, currency: cny, fixed: 2}
  ask: {fee: 0, currency: ltc, fixed: 4}
  sort_order: 2
  #visible: false     # default to true
```
### config/withdraw_channels.yml
```
- id: 600
  key: litecoin
  currency: ltc
  fixed: 8
  fee: 0.0005
  inuse: true
  type: WithdrawChannelLitecoin
```
Despues de terminar con los archivos de configuración seguimos con los ```controllers``` que realmente no son muchos cambios los que hay que hacer, solo sustituir variables practicamente

* app/controllers/admin/deposits/{coin}s_controller.rb
* app/controllers/admin/withdraws/{coins}s_controller.rb
* app/controllers/private/assets_controller.rb
* app/controllers/private/deposits/{coin}s_controller.rb
* app/controllers/private/withdraws/{coin}s_controller.rb

Seguimos con los ```models```

* app/models/admin/ability.rb
* app/models/deposits/{coin}.rb
* app/models/withdras/{coin}.rb

Tambien las vistas ```views```

* app/views/admin/deposits/{coin}s/index.html.slim
* app/views/admin/withdraws/{coin}s/_table.html.slim
* app/views/private/assets/_liability_tabs.html.slim
* app/views/private/assets/index.html.slim
* app/views/private/withdraws/{coin}s/new.html.slim

* app/assets/javascript/funds/models/withdraws.js.coffe

Por ultimo para que se visualicen los depositos y retiros hay que modificar los templates de la carpeta public

* public/templates/funds/deposit_{coin}.html
* public/templates/funds/deposit.html
* public/templates/withdraw_{coin}_.html
* public/templates/withdraw.html
