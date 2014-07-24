class AddTrustedIpListToAPITokens < ActiveRecord::Migration
  def change
    add_column :api_tokens, :trusted_ip_list, :string
  end
end
