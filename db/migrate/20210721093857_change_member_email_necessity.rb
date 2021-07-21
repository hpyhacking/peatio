class ChangeMemberEmailNecessity < ActiveRecord::Migration[5.2]
  def change
    change_column :members, :email, :string, null: true
  end
end
