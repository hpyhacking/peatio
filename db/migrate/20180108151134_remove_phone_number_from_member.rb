class RemovePhoneNumberFromMember < ActiveRecord::Migration
  def change
    remove_column :members, :phone_number
  end
end
