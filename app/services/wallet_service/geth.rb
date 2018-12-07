# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Geth < Base

    DEFAULT_ETH_FEE = { gas_limit: 21_000, gas_price: 1_000_000_000 }.freeze

    DEFAULT_ERC20_FEE = { gas_limit: 90_000, gas_price: 1_000_000_000 }.freeze

    def create_address(options = {})
      client.create_address!(options)
    end

    def collect_deposit!(deposit, options = {})
      if deposit.currency.code.eth?
        collect_eth_deposit!(deposit, options)
      else
        collect_erc20_deposit!(deposit, options)
      end
    end

    def build_withdrawal!(withdraw, options = {})
      if withdraw.currency.code.eth?
        build_eth_withdrawal!(withdraw, options)
      else
        build_erc20_withdrawal!(withdraw, options)
      end
    end

    def deposit_collection_fees(deposit, options = {})
      currency_options = deposit.currency.options.symbolize_keys

      # Calculate fees paid in gas for deposit collection of ERC20.
      # Use currency gas_limit and gas_price options if they are present.
      # Otherwise use DEFAULT_ERC20_FEE.
      eth_fees_value =
        if currency_options.key?(:gas_limit) && currency_options.key?(:gas_price)
          currency_options
        else
          DEFAULT_ERC20_FEE
        end.yield_self do |fee_opt|
          fee_opt.fetch(:gas_limit).to_i * fee_opt.fetch(:gas_price).to_i
        end

      # Set fees for deposit collection transaction.
      options = DEFAULT_ETH_FEE.merge options

      fee_wallet = erc20_fee_wallet
      destination_address = deposit.account.payment_address.address

      client.create_eth_withdrawal!(
        { address: fee_wallet.address, secret: fee_wallet.secret },
        { address: destination_address },
        eth_fees_value,
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

    def collect_eth_deposit!(deposit, options = {})
      currency_options = deposit.currency.options.symbolize_keys

      # ETH tx fees configuration:
      #   1. Defined in DEFAULT_ETH_FEE.
      #   2. deposit.currency.options override DEFAULT_ETH_FEE.
      #   3. options overrides deposit.currency.options.
      options = DEFAULT_ETH_FEE
                  .merge(currency_options.slice(:gas_limit, :gas_price))
                  .merge(options)

      pa = deposit.account.payment_address

      spread_hash = spread_deposit(deposit)
      spread_hash.map do |address, amount|
        spread_amount = amount * deposit.currency.base_factor - options[:gas_limit] * options[:gas_price]
        client.create_eth_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: address },
          spread_amount.to_i,
          options
        )
      end
    end

    def collect_erc20_deposit!(deposit, options = {})
      currency_options = deposit.currency.options.symbolize_keys

      # ERC20 tx fees configuration:
      #   1. Defined in DEFAULT_ERC20_FEE.
      #   2. deposit.currency.options override DEFAULT_ERC20_FEE.
      #   3. options overrides deposit.currency.options.
      options = DEFAULT_ERC20_FEE
                  .merge(currency_options.slice(:gas_limit, :gas_price))
                  .merge(options)

      pa = deposit.account.payment_address

      spread_hash = spread_deposit(deposit)
      spread_hash.map do |address, amount|
        spread_amount = amount * deposit.currency.base_factor
        client.create_erc20_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: address },
          spread_amount.to_i,
          options.merge(contract_address: deposit.currency.erc20_contract_address)
        )
      end
    end

    def build_eth_withdrawal!(withdraw, options = {})
      currency_options = withdraw.currency.options.symbolize_keys

      # ETH tx fees configuration:
      #   1. Defined in DEFAULT_ETH_FEE.
      #   2. deposit.currency.options override DEFAULT_ETH_FEE.
      #   3. options overrides deposit.currency.options.
      options = DEFAULT_ETH_FEE
                  .merge(currency_options.slice(:gas_limit, :gas_price))
                  .merge(options)

      client.create_eth_withdrawal!(
        { address: wallet.address, secret: wallet.secret },
        { address: withdraw.rid },
        withdraw.amount_to_base_unit!,
        options
      )
    end

    def build_erc20_withdrawal!(withdraw, options = {})
      currency_options = withdraw.currency.options.symbolize_keys

      # ERC20 tx fees configuration:
      #   1. Defined in DEFAULT_ERC20_FEE.
      #   2. deposit.currency.options override DEFAULT_ERC20_FEE.
      #   3. options overrides deposit.currency.options.
      options = DEFAULT_ERC20_FEE
                  .merge(currency_options.slice(:gas_limit, :gas_price))
                  .merge(options)

      client.create_erc20_withdrawal!(
        { address: wallet.address, secret: wallet.secret },
        { address: withdraw.rid },
        withdraw.amount_to_base_unit!,
        options.merge(contract_address: withdraw.currency.erc20_contract_address)
      )
    end
  end
end
