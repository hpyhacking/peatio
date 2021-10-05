class ChangeBlockchainCurrencyTableField < ActiveRecord::Migration[5.2]
  def up
    adapter_type = connection.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql, :mysql2
      execute("INSERT INTO blockchains (client, name, protocol, status, `key`, height, min_deposit_amount, withdraw_fee, min_withdraw_amount, min_confirmations, created_at, updated_at)
               VALUES ('fiat', 'Fiat Blockchain', 'Fiat', 'idle', 'fiat', 0, 0, 0, 0, 1, '#{Time.now}', '#{Time.now}')")
    when :postgresql
      execute("INSERT INTO blockchains (client, name, protocol, status, key, height, min_deposit_amount, withdraw_fee, min_withdraw_amount, min_confirmations, created_at, updated_at)
               VALUES ('fiat', 'Fiat Blockchain', 'Fiat', 'idle', 'fiat', 0, 0, 0, 0, 1, '#{Time.now}', '#{Time.now}')")
    end

    fiat_blockchain = Blockchain.find_by(client: 'fiat')

    PaymentAddress.all.where(blockchain_key: nil).find_each(batch_size: 100) do |payment_address|
      payment_address.update_columns(blockchain_key: fiat_blockchain.key)
    end

    Beneficiary.where(blockchain_key: nil).find_each(batch_size: 100) do |beneficiary|
      beneficiary.update_columns(blockchain_key: fiat_blockchain.key)
    end

    Withdraw.where(blockchain_key: nil).find_each(batch_size: 100) do |withdraws|
      withdraws.update_columns(blockchain_key: fiat_blockchain.key)
    end

    Deposit.where(blockchain_key: nil).find_each(batch_size: 100) do |deposit|
      deposit.update_columns(blockchain_key: fiat_blockchain.key)
    end

    BlockchainCurrency.where(blockchain_key: nil).find_each(batch_size: 100) do |blockchain_currency|
      blockchain_currency.update_columns(blockchain_key: fiat_blockchain.key)
    end

    change_column :blockchain_currencies, :blockchain_key, :string, null: false
    change_column :deposits, :blockchain_key, :string, null: false
    change_column :withdraws, :blockchain_key, :string, null: false
    change_column :payment_addresses, :blockchain_key, :string, null: false
    change_column :beneficiaries, :blockchain_key, :string, null: false
  end

  def down
    change_column :blockchain_currencies, :blockchain_key, :string, null: true
    change_column :deposits, :blockchain_key, :string, null: true
    change_column :withdraws, :blockchain_key, :string, null: true
    change_column :payment_addresses, :blockchain_key, :string, null: true
    change_column :beneficiaries, :blockchain_key, :string, null: true

    fiat_blockchain = Blockchain.find_by(client: 'fiat')

    PaymentAddress.where(blockchain_key: fiat_blockchain.key).find_each(batch_size: 100) do |payment_address|
      payment_address.update_columns(blockchain_key: nil)
    end

    Beneficiary.where(blockchain_key: fiat_blockchain.key).find_each(batch_size: 100) do |beneficiary|
      beneficiary.update_columns(blockchain_key: nil)
    end

    Withdraw.where(blockchain_key: fiat_blockchain.key).find_each(batch_size: 100) do |withdraws|
      withdraws.update_columns(blockchain_key: nil)
    end

    Deposit.where(blockchain_key: fiat_blockchain.key).find_each(batch_size: 100) do |deposit|
      deposit.update_columns(blockchain_key: nil)
    end

    BlockchainCurrency.where(blockchain_key: fiat_blockchain.key).find_each(batch_size: 100) do |blockchain_currency|
      blockchain_currency.update_columns(blockchain_key: nil)
    end

    fiat_blockchain.delete
  end
end
