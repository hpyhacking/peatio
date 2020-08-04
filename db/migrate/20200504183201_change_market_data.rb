class ChangeMarketData < ActiveRecord::Migration[5.2]
  def change
    add_column :markets, :data, :json, after: :position

    Market.all.each do |m|
      next if m.data_encrypted.nil?

      m.data = Vault::Rails.decrypt("transit", "#{Vault.application}_markets_data", m.data_encrypted)
      m.save
    end

    remove_column :markets, :data_encrypted
  end
end
