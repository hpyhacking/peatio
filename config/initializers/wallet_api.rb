Peatio::Wallet.registry[:bitcoind] = Bitcoin::Wallet
Peatio::Wallet.registry[:geth] = Ethereum::Eth::Wallet
Peatio::Wallet.registry[:parity] = Ethereum::Eth::Wallet
Peatio::Wallet.registry[:gnosis] = Gnosis::Wallet
Peatio::Wallet.registry[:"ow-hdwallet-eth"] = OWHDWallet::WalletETH
Peatio::Wallet.registry[:"ow-hdwallet-bsc"] = OWHDWallet::WalletBSC
Peatio::Wallet.registry[:"ow-hdwallet-heco"] = OWHDWallet::WalletHECO
Peatio::Wallet.registry[:opendax_cloud] = OpendaxCloud::Wallet
