class MigrationDataIdentityIdToMemberId < ActiveRecord::Migration
  def up
    execute <<-SQL
      DELETE FROM tokens WHERE type = 'ResetPin'
    SQL

    # We use safe_constantize here since we reference constant defined in app (we need to eager load it).
    if 'Token'.safe_constantize
      Token.all.each do |t|
        id = Member.find_by_identity_id(t.member_id)
        t.update_column :member_id, id
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
