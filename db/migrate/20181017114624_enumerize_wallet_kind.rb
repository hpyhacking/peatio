class EnumerizeWalletKind < ActiveRecord::Migration
  def change
    id_kind_hash = Wallet.pluck(:id, :kind).to_h

    remove_column :wallets, :kind
    add_column :wallets, :kind, :integer, limit: 4, null: false, after: :address

    Wallet.find_each { |w| w.update!(kind: id_kind_hash[w.id]) }

    add_index :wallets, :status
    add_index :wallets, :kind
    add_index :wallets, :currency_id
    add_index :wallets, %i[kind currency_id status]
  end
end
