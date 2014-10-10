class RemovePhoneNumberVerifiedFromMembers < ActiveRecord::Migration
  def change
    remove_column :members, :phone_number_verified
  end
end
