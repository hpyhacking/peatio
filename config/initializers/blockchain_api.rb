Peatio::Blockchain.registry[:bitcoin] = Bitcoin::Blockchain
Peatio::Blockchain.registry[:geth] = Ethereum::Eth::Blockchain
Peatio::Blockchain.registry[:parity] = Ethereum::Eth::Blockchain
Peatio::Blockchain.registry[:"geth-bsc"] = Ethereum::Bsc::Blockchain
Peatio::Blockchain.registry[:"geth-heco"] = Ethereum::Heco::Blockchain
Peatio::Blockchain.registry[:fiat] = Peatio::Fiat
