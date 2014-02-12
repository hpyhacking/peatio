class AddSnToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :sn, :string, after: :id
  end
end
