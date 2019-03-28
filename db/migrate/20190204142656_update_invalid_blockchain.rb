class UpdateInvalidBlockchain < ActiveRecord::Migration[4.2]
  def change
    Blockchain.where(client: 'ethereum').update_all(client: 'geth')      
  end
end
