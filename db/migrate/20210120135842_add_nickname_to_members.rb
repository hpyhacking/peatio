class AddNicknameToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :nickname, :string, null: true, after: :email
  end
end
