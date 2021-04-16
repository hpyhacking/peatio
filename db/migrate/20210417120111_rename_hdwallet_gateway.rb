class RenameHdwalletGateway < ActiveRecord::Migration[5.2]
  def up
    Wallet.where(gateway: %w[opendax ow_hdwallet]).each do |w|
      w.update(gateway: 'ow-hdwallet-eth')
    end
  end

  def down
    Wallet.where(gateway: %w[ow-hdwallet-eth]).each do |w|
      w.update(gateway: 'ow_hdwallet')
    end
  end
end
