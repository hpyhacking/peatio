class MigrationDataIdentityIdToMemberId < ActiveRecord::Migration
  def up
    execute <<-SQL
      DELETE FROM tokens WHERE type = 'ResetPin'
    SQL

    Token.all.each do |t|
      id = Member.find_by_identity_id(t.member_id)
      t.update_column :member_id, id
    end

    TwoFactor.all.each do |t|
      id = Member.find_by_identity_id(t.member_id)
      t.update_column :member_id, id
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
