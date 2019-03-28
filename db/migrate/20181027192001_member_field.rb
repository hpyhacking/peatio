class MemberField < ActiveRecord::Migration[4.2]
  def change

    change_table :members do |t|
      t.remove :level
      t.remove :sn
      t.remove :disabled
      t.remove :api_disabled
    end

    add_column :members, :uid,   :string,  after: :id,     null: false, limit: 12
    add_column :members, :level, :integer, after: :email,  null: false
    add_column :members, :role,  :string,  after: :level,  null: false, limit: 16
    add_column :members, :state, :string,  after: :role,   null: false, limit: 16
  end
end
