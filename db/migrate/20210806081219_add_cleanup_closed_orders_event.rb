class AddCleanupClosedOrdersEvent < ActiveRecord::Migration[5.2]
  def up_mysql
    execute 'DROP EVENT IF EXISTS cleanup_closed_orders_event;'
    execute <<-SQL
    CREATE EVENT IF NOT EXISTS cleanup_closed_orders_event
      ON SCHEDULE EVERY 1 DAY
        STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 1 HOUR)
      ON COMPLETION PRESERVE
      DO
        call cleanup_closed_orders(10000)
    SQL
  end

  def up
    case ActiveRecord::Base.connection.adapter_name
    # TODO: add PostgreSQL support
    when 'Mysql2'
      up_mysql
    end
  end
  def down
    case ActiveRecord::Base.connection.adapter_name
    when 'Mysql2'
      execute 'DROP EVENT IF EXISTS cleanup_closed_orders_event;'
    end
  end
end
