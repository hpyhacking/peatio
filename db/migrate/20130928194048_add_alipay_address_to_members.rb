class AddAlipayAddressToMembers < ActiveRecord::Migration
  def change
    add_column :members, :alipay, :string
    add_column :members, :state, :integer
  end
end
