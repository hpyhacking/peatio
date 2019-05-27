# Currency plugin development.

Peatio Plugin API v2 gives ability to extend Peatio with any coin
which fits into basic [Blockchain](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract) and [Wallet](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract)
interfaces described inside [peatio-core](https://github.com/rubykube/peatio-core) gem.

## Development.

### Start from reading Blockchain and Wallet doc.

You need to be familiar with [Blockchain](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract)
and [Wallet](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract) interfaces.

**Note:** *you can skip optional methods if they are not supported by your coin.*

### Coin API research.

First of all need to start your coin node locally or inside VM and try to access it via HTTP e.g. using `curl` or `http`.
You need to study your coin API to get list of calls for implementing [Blockchain](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract) and
[Wallet](https://www.rubydoc.info/gems/peatio/0.5.0/Peatio/Blockchain/Abstract) interfaces. 

**Note:** *single method may require multiple API calls.*

We next list of JSON RPC methods for Bitcoin integration:
  * getbalance
  * getblock  
  * getblockcount
  * getblockhash
  * getnewaddress
  * listaddressgroupings
  * sendtoaddress
  
For Ethereum Blockchain (ETH, ERC20) we use next list of methods:
  * eth_blockNumber
  * eth_getBalance
  * eth_call
  * eth_getTransactionReceipt
  * eth_getBlockByNumber
  * personal_newAccount
  * personal_sendTransaction
  
### Ruby gem development.

During this step you will create your own ruby gem for implementing your coin Blockchain and Wallet classes.

We will use [peatio-litecoin](https://github.com/rubukybe/peatio-litecoin) as example.
My advice is to clone it and use as plugin development guide.

For more currencies examples check [Bitcoin](../../lib/peatio/bitcoin) and [Ethereum](../../lib/peatio/ethereum) implementation.

1. ***Create a new gem. And update .gemspec.*** 💎

```bash
bundle gem peatio-litecoin
```
**Note:** *there is no requirements for gem naming and module hierarchy.*

2. ***Add your gem dependencies to .gemspec.*** 🛠

I use the next list of gems (you could specify preferred by you inside you gem):
```ruby
  spec.add_dependency "activesupport", "~> 5.2.3"
  spec.add_dependency "better-faraday", "~> 1.0.5"
  spec.add_dependency "faraday", "~> 0.15.4"
  spec.add_dependency "memoist", "~> 0.16.0"
  spec.add_dependency "peatio", "~> 0.6.1"          # Required.
  
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "mocha", "~> 1.8"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.5"
```

**Note:** *peatio gem is required.*

3. ***Install your dependencies.️*** ⚙

```bash
bundle install
```

4. ***Save responses in spec/resources.*** 📥

You could start from saving few responses and then extend your mock factory.
Peatio-litecoin spec/resources directory has the following structure:

```bash
tree spec/resources
spec/resources
├── getbalance
│   └── response.json
├── getblock
│   └── 40500.json
├── getblockcount
│   └── 40500.json
├── getblockhash
│   └── 40500.json
├── getnewaddress
│   └── response.json
├── listaddressgroupings
│   └── response.json
├── methodnotfound
│   └── error.json
└── sendtoaddress
    └── response.json
```

5. ***Prepare your gem structure.*** 📐

You could organize files and directories as you wish.
Peatio-litecoin has the following lib and spec structure:

```bash
tree lib
lib
└── peatio
   ├── litecoin
   │   ├── blockchain.rb
   │   ├── client.rb
   │   ├── hooks.rb
   │   ├── railtie.rb
   │   ├── version.rb
   │   └── wallet.rb
   └── litecoin.rb
   
tree spec/peatio
spec/peatio
├── litecoin
│   ├── blockchain_spec.rb
│   ├── client_spec.rb
│   └── wallet_spec.rb
└── litecoin_spec.rb
```

6. ***Start with your coin client implementation.*** 🥚

First of all try to find reliable ruby client for your coin and implement own if there is no such. 
We don't provide client interface so you could construct client in the way it's convenient for you
but note that it's your gem base because you will use it widely during Blockchain and Wallet implementation.
   
7. ***Try to call API with your client. Use ./bin/console for this.*** 📮

```ruby
client = Peatio::Litecoin::Client.new('http://user:password@127.0.0.1:19332') # => #<Peatio::Litecoin::Client:0x00007fca61d82650 @json_rpc_endpoint=#<URI::HTTP http://user:password@127.0.0.1:19332>>
client.json_rpc(:getblockcount) # => 1087729
client.json_rpc(:getnewaddress) # => "QQPyC9uTQ1YKu3V1Dr4rNqHkHgJG3qr8JC"
```

8. ***Use spec/resources for client testing.*** 🧰

E.g. specs for peatio-litecoin client:

```bash
bundle exec rspec spec/peatio/litecoin/client_spec.rb

Peatio::Litecoin::Client
  initialize
    should not raise Exception
  json_rpc
    getblockcount
      should not raise Exception
      should eq 40500
    methodnotfound
      should raise Peatio::Litecoin::Client::ResponseError with "Method not found (-32601)"
    notfound
      should raise Peatio::Litecoin::Client::Error
    connectionerror
      should raise Peatio::Litecoin::Client::ConnectionError

Finished in 0.01355 seconds (files took 1.11 seconds to load)
6 examples, 0 failures
```

9. ***Implement Blockchain::Abstract interface required methods.*** 🔗

```ruby
module Peatio
  module Litecoin
    class Blockchain < Peatio::Blockchain::Abstract
    # Your custom logic goes here.
    end
  end
end
```

I suggest using the next order of methods implementation:

    * initialize
    * configure
    * latest_block_number
    * fetch_block!
    * load_balance_of_address! (optional)

10. ***Mock API calls using spec/resources and test your blockchain.️*** 🛡

E.g. specs for peatio-litecoin blockchain:

```bash
Peatio::Litecoin::Blockchain
  features
    defaults
    override defaults
    custom feautures
  configure
    default settings
    currencies and server configuration
  latest_block_number
    returns latest block number
    raises error if there is error in response body
  build_transaction
    three vout tx
      builds formatted transactions for passed transaction
    multiple currencies
      builds formatted transactions for passed transaction per each currency
    single vout transaction
      builds formatted transactions for each vout
  fetch_block!
    builds expected number of transactions
    all transactions are valid
  load_balance_of_address!
    address with balance is defined
      requests rpc listaddressgroupings and finds address balance
      requests rpc listaddressgroupings and finds address with zero balance
    address is not defined
      requests rpc listaddressgroupings and do not find address
    client error is raised
      raise wrapped client error

Finished in 0.02604 seconds (files took 1.14 seconds to load)
16 examples, 0 failures
```


11. ***Implement Wallet::Abstract interface required methods.*** 💸

```ruby
module Peatio
  module Litecoin
    class Wallet < Peatio::Blockchain::Abstract
    # Your custom logic goes here.
    end
  end
end
``` 

I suggest using the next order of methods implementation:

    * initialize
    * configure
    * create_address!
    * create_transaction!
    * load_balance! (optional)

12. ***Mock API calls using spec/resources and test your wallet.*** 🔐️

E.g. specs for peatio-litecoin wallet:

```bash
Peatio::Litecoin::Wallet
  configure
    requires wallet
    requires currency
    sets settings attribute
  create_address!
    request rpc and creates new address
  create_transaction!
    requests rpc and sends transaction without subtract fees
  load_balance!
    requests rpc with getbalance call

Finished in 0.01205 seconds (files took 1.08 seconds to load)
6 examples, 0 failures
```

13. ***Register your plugin blockchain and wallet to make it accessible by Peatio.️*** ®

```ruby
Peatio::Blockchain.registry[:litecoin] = Litecoin::Blockchain.new
Peatio::Wallet.registry[:litecoind] = Litecoin::Wallet.new
```

For more info check hooks.rb and railtie.rb.

**Note:** *You could just copy paste this files and change wallet and blockchain names.*

14. ***Test your plugin inside peatio eco system.*** 🧪

Every story which touch blockchain or wallet should work successfully:

    * deposit address generation
    * deposit detection
    * blockchain synchronization
    * deposit collection
    * withdraw creation
    * withdraw confirmation

15. ***Document your plugin integration steps.*** 📝

Documentation folder for Litecoin has the following structure:
```bash
docs
├── integration.md
├── json-rpc.md
└── testnet.md
```

* integration.md

    Describe full plugin integration flow in integration.md.
    **Image Build** and **Peatio Configuration** sections are required.

    **Don't forget to describe custom steps here e.g.**
    
    *"Send some XRP for wallet activation"* or *"For ERC20 integration fee wallet with ETH is required"*.

* json-rpc.md

    List all API calls used for gem development here with examples and description.

* testnet.md

    Give instructions how to get coins in testent.

**Note:** it's minimalistic doc structure. More doc is more love for your plugin.

16. Contact us to review your plugin and add to [approved plugins list](../plugins.md).

For doing it left comment with your plugin link and short description [here](https://github.com/rubykube/peatio/issues/2212).
