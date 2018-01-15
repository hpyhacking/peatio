class DropSignin < ActiveRecord::Migration
  def change
    drop_table :identities
    drop_table :tokens
  end
end
