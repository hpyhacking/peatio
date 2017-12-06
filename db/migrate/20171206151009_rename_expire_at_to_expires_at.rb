class RenameExpireAtToExpiresAt < ActiveRecord::Migration
  def change
    %i[ tokens api_tokens ].each do |t|
      rename_column(t, :expire_at, :expires_at) if column_exists?(t, :expire_at)
    end
  end
end
