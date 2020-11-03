class UpdateOrderState < ActiveRecord::Migration[5.0]
  def up
    case ActiveRecord::Base.connection.adapter_name
    when 'Mysql2'
      execute('UPDATE orders SET orders.state = -100 WHERE orders.state = 0')
    when 'PostgreSQL'
      execute('UPDATE "orders" SET "state" = -100 WHERE "orders"."state" = 0')
    else
      raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
    end
  end

  def down
    case ActiveRecord::Base.connection.adapter_name
    when 'Mysql2'
      execute('UPDATE orders SET orders.state = 0 WHERE orders.state = -100')
    when 'PostgreSQL'
      execute('UPDATE "orders" SET "state" = 0 WHERE "orders"."state" = -100')
    else
      raise "Unsupported adapter: #{ActiveRecord::Base.connection.adapter_name}"
    end
  end
end
