# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :blockchain do

    trait 'fiat' do
      key                     { 'fiat' }
      name                    { 'Fiat Network' }
      client                  { 'fiat' }
      protocol                { 'Fiat Protocol' }
      status                  { 'idle' }
    end

    trait 'eth-rinkeby' do
      key                     { 'eth-rinkeby' }
      name                    { 'Ethereum Rinkeby' }
      client                  { 'geth' }
      server                  { 'http://127.0.0.1:8545' }
      height                  { 2500000 }
      min_confirmations       { 6 }
      explorer_address        { 'https://etherscan.io/address/#{address}' }
      explorer_transaction    { 'https://etherscan.io/tx/#{txid}' }
      warning                 { 'Reminder: For the safety of your funds, please confirm again that the network you wish to use is eth-rinkeby.' }
      protocol                { 'Rinkeby' }
      description             { 'Ethereum Rinkeby' }
      collection_gas_speed    { 'standard' }
      withdrawal_gas_speed    { 'standard' }
      status                  { 'active' }
    end

    trait 'eth-kovan' do
      key                     { 'eth-kovan' }
      name                    { 'Ethereum Kovan' }
      client                  { 'parity' }
      server                  { 'http://127.0.0.1:8545' }
      height                  { 2500000 }
      min_confirmations       { 6 }
      explorer_address        { 'https://kovan.etherscan.io/address/#{address}' }
      explorer_transaction    { 'https://kovan.etherscan.io/tx/#{txid}' }
      warning                 { 'Reminder: For the safety of your funds, please confirm again that the network you wish to use is eth-kovan.' }
      protocol                { 'Kovan' }
      description             { 'Ethereum Kovan' }
      collection_gas_speed    { 'standard' }
      withdrawal_gas_speed    { 'standard' }
      status                  { 'active' }
    end

    trait 'eth-mainet' do
      key                     { 'eth-mainet' }
      name                    { 'Ethereum Mainet' }
      client                  { 'geth' }
      server                  { 'http://127.0.0.1:8545' }
      height                  { 2500000 }
      min_confirmations       { 4 }
      explorer_address        { 'https://etherscan.io/address/#{address}' }
      explorer_transaction    { 'https://etherscan.io/tx/#{txid}' }
      warning                 { 'Reminder: For the safety of your funds, please confirm again that the network you wish to use is eth-mainet.' }
      protocol                { 'ERC-20' }
      description             { 'Ethereum Mainet' }
      collection_gas_speed    { 'standard' }
      withdrawal_gas_speed    { 'standard' }
      status                  { 'disabled' }
    end

    trait 'btc-testnet' do
      key                     { 'btc-testnet' }
      name                    { 'Bitcoin Testnet' }
      client                  { 'bitcoin' }
      server                  { 'http://127.0.0.1:18332' }
      height                  { 1350000 }
      min_confirmations       { 1 }
      explorer_address        { 'https://blockchain.info/address/#{address}' }
      explorer_transaction    { 'https://blockchain.info/tx/#{txid}' }
      warning                 { 'Reminder: For the safety of your funds, please confirm again that the network you wish to use is btc-testnet.' }
      protocol                { 'BEP-2' }
      description             { 'Bitcoin Testnet' }
      status                  { 'active' }
    end

    trait 'fake-testnet' do
      key                     { 'fake-testnet' }
      name                    { 'Fake Testnet' }
      client                  { 'fake' }
      height                  { 1 }
      warning                 { 'Reminder: For the safety of your funds, please confirm again that the network you wish to use is fake-testnet.' }
      protocol                { 'Fake'}
      description             { 'Fake Testnet' }
      status                  { 'active' }
    end
  end
end
