class AddBeneficiariesEnabledToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :beneficiaries_whitelisting, :bool, after: :group
    add_column :beneficiaries, :expire_at, :datetime, after: :sent_at
  end
end
