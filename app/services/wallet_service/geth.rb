# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Geth < Base

    DEFAULT_ETH_FEE = { gas_limit: 21_000, gas_price: 10_000_000_000 }.freeze

    DEFAULT_ERC20_FEE_VALUE =  100_000 * DEFAULT_ETH_FEE[:gas_price]

    def create_address(options = {})
      client.create_address!(options)
    end

    def collect_deposit!(deposit, options={})
      destination_address = destination_wallet(deposit).address
      if deposit.currency.code.eth?
        collect_eth_deposit!(deposit, destination_address, options)
      else
        collect_erc20_deposit!(deposit, destination_address, options)
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
      fees_wallet = eth_fees_wallet
      destination_address = deposit.account.payment_address.address
      options = DEFAULT_ETH_FEE.merge options

      client.create_eth_withdrawal!(
        { address: fees_wallet.address, secret: fees_wallet.secret },
        { address: destination_address },
        value,
        options
      )
    end

    private

    def eth_fees_wallet
      Wallet
        .active
        .withdraw
        .find_by(currency_id: :eth, kind: :hot)
    end

    def collect_eth_deposit!(deposit, destination_address, options={})
      # Default values for Ethereum tx fees.
      options = DEFAULT_ETH_FEE.merge options

      # We can't collect all funds we need to subtract gas fees.
      amount = deposit.amount_to_base_unit! - options[:gas_limit] * options[:gas_price]
      pa = deposit.account.payment_address
      client.create_eth_withdrawal!(
        { address: pa.address, secret: pa.secret },
        { address: destination_address },
        amount,
        options
      )
    end

    def collect_erc20_deposit!(deposit, destination_address, options={})
      pa = deposit.account.payment_address

      client.create_erc20_withdrawal!(
        { address: pa.address, secret: pa.secret },
        { address: destination_address },
        deposit.amount_to_base_unit!,
        options.merge(contract_address: deposit.currency.erc20_contract_address )
      )

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
