# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Bitcoind < Base

    def create_address(options = {})
      @client.create_address!(options)
    end

    def collect_deposit!(deposit, options={})
      pa = deposit.account.payment_address

      # This will automatically deduct fee from amount so we can withdraw exact amount.
      options = options.merge( subtract_fee: true )
      spread_hash = spread_deposit(deposit)
      spread_hash.map do |address, amount|
        client.create_withdrawal!(
          { address: pa.address },
          { address: address},
          amount,
          options
        )
      end
    end

    def build_withdrawal!(withdraw, options = {})
      client.create_withdrawal!(
        { address: wallet.address },
        { address: withdraw.rid },
        withdraw.amount,
        options
      )
    end

    def load_balance(address, currency)
      client.load_balance!(address, currency)
    end
  end
end
