class RenameIdentityIdToMemberId < ActiveRecord::Migration
  def change
    change_table :tokens do |t|
      t.rename :identity_id, :member_id
    end

    change_table :two_factors do |t|
      t.rename :identity_id, :member_id
    end
  end
end
