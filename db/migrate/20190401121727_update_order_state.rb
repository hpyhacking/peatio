class UpdateOrderState < ActiveRecord::Migration[5.0]
  def change
    execute('UPDATE orders SET orders.state = -100 WHERE orders.state = 0')
  end
end
