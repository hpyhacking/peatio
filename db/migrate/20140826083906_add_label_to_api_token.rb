class AddLabelToAPIToken < ActiveRecord::Migration
  def change
    add_column :api_tokens, :label, :string
  end
end
