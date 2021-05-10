class AddRemoteIdField < ActiveRecord::Migration[5.2]
  def change
    add_column :withdraws, :remote_id, :string, after: :rid
  end
end
