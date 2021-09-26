class AddAccountType < ActiveRecord::Migration[5.2]
  def change
    unless column_exists?(:accounts, :type)
      add_column :accounts, :type, :string, default: :spot, null: false, after: :currency_id
      remove_index :accounts, column: %i[currency_id member_id]
      add_index :accounts, %i[currency_id member_id type], unique: true, name: 'index_accounts_on_currency_id_and_member_id_and_type_and_unique'
      remove_index :operations_accounts, column: %i[type kind currency_type]
      add_index :operations_accounts, %i[type kind currency_type code], name: 'index_operations_accounts_on_type_kind_currency_type_code'
      if ActiveRecord::Base.connection.primary_key('accounts') == %w[currency_id member_id]
        adapter_type = connection.adapter_name.downcase.to_sym
        case adapter_type
        when :mysql, :mysql2
          execute('ALTER TABLE accounts DROP PRIMARY KEY, ADD PRIMARY KEY(currency_id, member_id, type)')
        when :postgresql
          execute('ALTER TABLE accounts DROP CONSTRAINT accounts_pkey')
          execute('ALTER TABLE accounts ADD PRIMARY KEY(currency_id, member_id, type)')
        end
      end
    end
  end
end
