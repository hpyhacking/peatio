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
