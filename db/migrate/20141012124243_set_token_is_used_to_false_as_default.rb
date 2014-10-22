class SetTokenIsUsedToFalseAsDefault < ActiveRecord::Migration
  def change
    change_column :tokens, :is_used, :boolean, default: false
  end
end
