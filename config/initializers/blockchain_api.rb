Peatio::Blockchain.registry[:bitcoin] = Bitcoin::Blockchain.new
Peatio::Blockchain.registry[:geth] = Ethereum::Blockchain.new
Peatio::Blockchain.registry[:parity] = Ethereum::Blockchain.new
