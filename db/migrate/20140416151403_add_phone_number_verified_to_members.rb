class AddPhoneNumberVerifiedToMembers < ActiveRecord::Migration
  def change
    add_column :members, :phone_number_verified, :boolean
  end
end
