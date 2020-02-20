class RevertOrderTimestampPrecision < ActiveRecord::Migration[5.2]
  def change
    %w[created_at updated_at].each do |ts|
      change_column :orders, ts, :datetime, limit: 0
    end
  end
end
