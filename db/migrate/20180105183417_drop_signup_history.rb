class DropSignupHistory < ActiveRecord::Migration
  def change
    drop_table :signup_histories
  end
end
