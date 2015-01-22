class AddSignupHistories < ActiveRecord::Migration
  def change
    create_table :signup_histories do |t|
      t.references :member, index: true
      t.string :ip
      t.string :accept_language
      t.string :ua
      t.datetime :created_at
    end
  end
end
