class AddCleanupClosedOrders < ActiveRecord::Migration[5.2]
  def up_mysql
    execute 'DROP PROCEDURE IF EXISTS `cleanup_closed_orders`;'
    execute <<-SQL
    CREATE PROCEDURE cleanup_closed_orders (count INT)
      BEGIN
          -- Variables
          DECLARE last_deleted_count INT DEFAULT count;
          DECLARE total_deleted_count INT DEFAULT 0;

          -- Main loop
          WHILE last_deleted_count = count DO

              -- Delete cancelled orders without trades older than 1 week in batches(using count)
              DELETE FROM orders WHERE `state` = -100 AND trades_count = 0 AND created_at < NOW() - INTERVAL 1 WEEK LIMIT count;
              
              -- Select deleted rows
              SET last_deleted_count = ROW_COUNT();

              -- Sum of delete rows during loop execution
              SET total_deleted_count = total_deleted_count + last_deleted_count;

              -- Return total deleted rows
              SELECT total_deleted_count;

              -- Sleep 0.1 sec.
              DO SLEEP(0.1);
          END WHILE;

          -- Return total delete count after loop execution
          SELECT total_deleted_count;
      END
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
      execute 'DROP PROCEDURE IF EXISTS cleanup_closed_orders;'
    end
  end
end
