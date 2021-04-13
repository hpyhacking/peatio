module PrimaryKeyMigration
  extend ActiveSupport::Concern

  def renew_primary_key(table_name, new_primary_key)
    adapter_type = connection.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql, :mysql2
      ActiveRecord::Base.transaction do
        execute("ALTER TABLE #{table_name} DROP PRIMARY KEY")
        add_column(table_name, new_primary_key, :primary_key)
      end
    when :postgresql
      ActiveRecord::Base.transaction do
        execute("ALTER TABLE #{table_name} DROP CONSTRAINT #{table_name}_pkey")
        add_column(table_name, new_primary_key, :primary_key)
      end
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end
  end

  def drop_primary_key(table_name, old_primary_key, new_primary_keys)
    adapter_type = connection.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql, :mysql2
      ActiveRecord::Base.transaction do
        # Change ID field to be not autoincremented
        execute("ALTER TABLE #{table_name} MODIFY #{old_primary_key} INT NOT NULL")
        # Assign primary key other values
        execute("ALTER TABLE #{table_name} DROP PRIMARY KEY, ADD PRIMARY KEY(#{new_primary_keys.join(', ')})")
        # Delete ID field
        remove_column(table_name, old_primary_key) if ActiveRecord::Base.connection.column_exists?(table_name, old_primary_key)
      end
    when :postgresql
      ActiveRecord::Base.transaction do
        execute("ALTER TABLE #{table_name} DROP CONSTRAINT #{table_name}_pkey")
        execute("ALTER TABLE #{table_name} ADD PRIMARY KEY(#{new_primary_keys.join(', ')})")
        # Delete ID field
        remove_column(table_name, old_primary_key) if ActiveRecord::Base.connection.column_exists?(table_name, old_primary_key)
      end
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end
  end

  def run_primary_key_migration(mysql_type, postgresql_type, table_names)
    adapter_type = connection.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql, :mysql2
      ActiveRecord::Base.transaction do
        table_names.each do |table_name|
          execute("ALTER TABLE #{table_name} MODIFY COLUMN id #{mysql_type} NOT NULL AUTO_INCREMENT")
        end
      end
    when :postgresql
      ActiveRecord::Base.transaction do
        table_names.each do |table_name|
          execute("ALTER TABLE #{table_name} ALTER COLUMN id SET DATA TYPE #{postgresql_type}")
        end
      end
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end
  end
end
