class ChangeAccountPrimaryKey < ActiveRecord::Migration[5.2]
  def up
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

  def down
    if ActiveRecord::Base.connection.primary_key('accounts') == %w[currency_id member_id type]
      adapter_type = connection.adapter_name.downcase.to_sym
      case adapter_type
      when :mysql, :mysql2
        execute('ALTER TABLE accounts DROP PRIMARY KEY, ADD PRIMARY KEY(currency_id, member_id)')
      when :postgresql
        execute('ALTER TABLE accounts DROP CONSTRAINT accounts_pkey')
        execute('ALTER TABLE accounts ADD PRIMARY KEY(currency_id, member_id)')
      end
    end
  end
end
