class UpdateInvalidBlockchain < ActiveRecord::Migration
  def change
    Blockchain.where(client: 'ethereum').update_all(client: 'geth')      
  end
end
