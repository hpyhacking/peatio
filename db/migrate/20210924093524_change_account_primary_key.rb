class ChangeAccountPrimaryKey < ActiveRecord::Migration[5.2]
  def up
    if ActiveRecord::Base.connection.primary_key('accounts') == %w[currency_id member_id]
      execute('ALTER TABLE accounts DROP PRIMARY KEY, ADD PRIMARY KEY(currency_id, member_id, type)')
    end
  end

  def down
    if ActiveRecord::Base.connection.primary_key('accounts') == %w[currency_id member_id type]
      execute('ALTER TABLE accounts DROP PRIMARY KEY, ADD PRIMARY KEY(currency_id, member_id)')
    end
  end
end
