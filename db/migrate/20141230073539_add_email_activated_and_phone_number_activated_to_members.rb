class AddEmailActivatedAndPhoneNumberActivatedToMembers < ActiveRecord::Migration
  def change
    rename_column :members, :activated, :email_activated
    add_column :members, :phone_number_activated, :boolean
  end
end
