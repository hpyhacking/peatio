class AddPhoneNumberToMembers < ActiveRecord::Migration
  def change
    add_column :members, :phone_number, :string
  end
end
