# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Geth < Base

    DEFAULT_ETH_FEE = { gas_limit: 21_000, gas_price: 1_000_000_000 }.freeze

    DEFAULT_ERC20_FEE_VALUE =  100_000 * DEFAULT_ETH_FEE[:gas_price]

    def create_address(options = {})
      client.create_address!(options)
    end

    def collect_deposit!(deposit, options={})
      destination_wallets = destination_wallets(deposit)
      if deposit.currency.code.eth?
        collect_eth_deposit!(deposit, destination_wallets, options)
      else
        collect_erc20_deposit!(deposit, destination_wallets, options)
      end
    end

    def build_withdrawal!(withdraw)
      if withdraw.currency.code.eth?
        build_eth_withdrawal!(withdraw)
      else
        build_erc20_withdrawal!(withdraw)
      end
    end

    def deposit_collection_fees(deposit, value=DEFAULT_ERC20_FEE_VALUE, options={})
      fee_wallet = erc20_fee_wallet
      destination_address = deposit.account.payment_address.address
      options = DEFAULT_ETH_FEE.merge options

      client.create_eth_withdrawal!(
        { address: fee_wallet.address, secret: fee_wallet.secret },
        { address: destination_address },
        value,
        options
      )
    end

    def load_balance(address, currency)
      client.load_balance!(address, currency)
    end

    private

    def erc20_fee_wallet
      Wallet
        .active
        .find_by(currency_id: :eth, kind: :fee)
    end

    def collect_eth_deposit!(deposit, destination_wallets, options={})
      # Default values for Ethereum tx fees.
      options = DEFAULT_ETH_FEE.merge options
      pa = deposit.account.payment_address
      spread_hash = spread_deposit(deposit)
      spread_hash.map do |address, amount|
        spread_amount = amount * deposit.currency.base_factor - options[:gas_limit] * options[:gas_price]
        client.create_eth_withdrawal!(
            { address: pa.address, secret: pa.secret },
            { address: address},
            spread_amount.to_i,
            options
        )
      end
    end

    def collect_erc20_deposit!(deposit, destination_wallets, options={})
      pa = deposit.account.payment_address

      spread_hash = spread_deposit(deposit)
      spread_hash.map do |address, amount|
        spread_amount = amount * deposit.currency.base_factor
        client.create_erc20_withdrawal!(
            { address: pa.address, secret: pa.secret },
            { address: address},
            spread_amount.to_i,
            options.merge( contract_address: deposit.currency.erc20_contract_address )
        )
      end
    end

    def build_eth_withdrawal!(withdraw)
      client.create_eth_withdrawal!(
        { address: wallet.address, secret: wallet.secret },
        { address: withdraw.rid },
        withdraw.amount_to_base_unit!
      )
    end

    def build_erc20_withdrawal!(withdraw)
      client.create_erc20_withdrawal!(
        { address: wallet.address, secret: wallet.secret },
        { address: withdraw.rid },
        withdraw.amount_to_base_unit!,
        {contract_address: withdraw.currency.erc20_contract_address}
      )
    end
  end
end
