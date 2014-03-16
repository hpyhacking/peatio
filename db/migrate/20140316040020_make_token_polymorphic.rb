class MakeTokenPolymorphic < ActiveRecord::Migration
  def change
    rename_column :tokens, :member_id, :tokenable_id
    add_column :tokens, :tokenable_type, :string, default: 'Member'
  end
end
