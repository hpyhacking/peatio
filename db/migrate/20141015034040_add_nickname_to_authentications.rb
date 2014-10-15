class AddNicknameToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :nickname, :string
  end
end
