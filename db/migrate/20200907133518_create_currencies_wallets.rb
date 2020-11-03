class CreateCurrenciesWallets < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        create_join_table :currencies, :wallets do |t|
          t.string :currency_id, index: true
          t.integer :wallet_id, index: true
        end
        add_index :currencies_wallets, %i[currency_id wallet_id], unique: true
        # Add links for the existing wallets and currencies
        # Make sure to join wallets with currencies after migration via admin API
        Wallet.find_each do |w|
          CurrencyWallet.create(wallet_id: w.id, currency_id: w.currency_id)
        end

        add_reference :payment_addresses, :member, index: true, after: :id
        add_reference :payment_addresses, :wallet, index: true, after: :member_id
        # Update old PaymentAddresses with wallet_id and memmber_id columns
        # We will still have in DB old PAs but after join wallets system will display
        # and use only one address
        PaymentAddress.find_in_batches do |batch|
          batch.each do |pa|
            wallet = Wallet.deposit.find_by(currency_id: pa.currency_id)
            ac = Account.find_by(id: pa.account_id)
            next if wallet.blank? || ac.blank?

            pa.update!(wallet_id: wallet.id, member_id: ac.member_id)
          end
        end
        change_column_default :currencies, :options, nil
        remove_column :wallets, :currency_id
        remove_index :payment_addresses, column: [:currency_id, :address]
        remove_column :payment_addresses, :currency_id
        remove_column :payment_addresses, :account_id

        case ActiveRecord::Base.connection.adapter_name
        when 'Mysql2'
          change_column :currencies, :options, :json
        when 'PostgreSQL'
          execute 'ALTER TABLE currencies ALTER COLUMN options TYPE json USING (options::json)'
        else
          raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
        end
      end

      dir.down do
        add_column :wallets, :currency_id, :string, limit: 10, after: :blockchain_key
        # Create wallets for each currency with append currency_id to the wallet name to avoid uniq name validation
        # Check wallets info after rollback migration via admin API
        Wallet.find_each do |w|
          w.currency_ids.each do |c_id|
            wallet_params = w.as_json.symbolize_keys
            wallet_params[:name] = "#{w.name} #{c_id}"
            wallet_params[:currency_id] = c_id
            Wallet.create!(wallet_params.except(:id))
          end
        end
        # Delete old wallets
        Wallet.where(currency_id: nil).delete_all

        # For payment_addresses user will need to generate new addresses
        add_column :payment_addresses, :currency_id, :string, limit: 10, after: :id
        add_column :payment_addresses, :account_id, :integer, after: :currency_id
        # Delete old payment_addresses
        PaymentAddress.where(account_id: nil, currency_id: nil).delete_all
        remove_column :payment_addresses, :member_id
        remove_column :payment_addresses, :wallet_id
        change_column :currencies, :options, limit: 1000, default: "{}"
        drop_table :currencies_wallets
      end
    end
  end
end
