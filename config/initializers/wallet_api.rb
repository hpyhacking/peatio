Peatio::Wallet.registry[:bitcoind] = Bitcoin::Wallet.new
Peatio::Wallet.registry[:geth] = Ethereum::Wallet.new
Peatio::Wallet.registry[:peth] = Ethereum::Wallet.new
