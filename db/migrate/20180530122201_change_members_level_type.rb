# frozen_string_literal: true

class ChangeMembersLevelType < ActiveRecord::Migration[4.2]
  def up
    add_column :members, :level_int, :integer, default: 0, null: false, limit: 1

    Member.where(level: nil).update_all(level_int: 0)
    Member.where(level: '').update_all(level_int: 0)
    Member.where(level: 'unverified').update_all(level_int: 0)
    Member.where(level: 'email_verified').update_all(level_int: 1)
    Member.where(level: 'phone_verified').update_all(level_int: 2)
    Member.where(level: 'identity_verified').update_all(level_int: 3)

    remove_column :members, :level
    rename_column :members, :level_int, :level
  end

  def down
    change_column :members, :level, :string, null: true, limit: 20
    change_column_default :members, :level, ''

    Member.where(level: 0).update_all(level: 'unverified')
    Member.where(level: 1).update_all(level: 'email_verified')
    Member.where(level: 2).update_all(level: 'phone_verified')
    Member.where(level: 3).update_all(level: 'identity_verified')
  end
end
