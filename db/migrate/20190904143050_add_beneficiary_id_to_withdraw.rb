class AddBeneficiaryIdToWithdraw < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :beneficiary_id, :bigint, null: true, after: :member_id
  end
end
