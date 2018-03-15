class RemoveInAndOut < ActiveRecord::Migration
  def change
    remove_columns :accounts, :in, :out
  end
end
