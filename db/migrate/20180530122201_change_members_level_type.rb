# encoding: UTF-8
# frozen_string_literal: true

class ChangeMembersLevelType < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        execute "update members set level = '0' where level is null or level = '' or level = 'unverified';"
        execute "update members set level = '1' where level = 'email_verified';"
        execute "update members set level = '2' where level = 'phone_verified';"
        execute "update members set level = '3' where level = 'identity_verified';"
        change_column :members, :level, :integer, default: 0, null: false, limit: 1
      end
      direction.down do
        change_column :members, :level, :string, null: true, limit: 20
        change_column_default :members, :level, ''
        execute "update members set level = 'unverified' where level = '0';"
        execute "update members set level = 'email_verified' where level = '1';"
        execute "update members set level = 'phone_verified' where level = '2';"
        execute "update members set level = 'identity_verified' where level = '3';"
      end
    end
  end
end
