class IncreaseTimestampPrecision < ActiveRecord::Migration[5.2]
  def up
    change_column(:trades, :created_at, :datetime, limit: 3)
    change_column(:trades, :updated_at, :datetime, limit: 3)
    change_column(:adjustments, :created_at, :datetime, limit: 3)
    change_column(:adjustments, :updated_at, :datetime, limit: 3)
    change_column(:transfers, :created_at, :datetime, limit: 3)
    change_column(:transfers, :updated_at, :datetime, limit: 3)
    change_column(:deposits, :created_at, :datetime, limit: 3)
    change_column(:deposits, :updated_at, :datetime, limit: 3)
    change_column(:deposits, :completed_at, :datetime, limit: 3)
    change_column(:withdraws, :created_at, :datetime, limit: 3)
    change_column(:withdraws, :updated_at, :datetime, limit: 3)
    change_column(:withdraws, :completed_at, :datetime, limit: 3)
  end

  def down
    change_column(:trades, :created_at, :datetime, limit: 0)
    change_column(:trades, :updated_at, :datetime, limit: 0)
    change_column(:adjustments, :created_at, :datetime, limit: 0)
    change_column(:adjustments, :updated_at, :datetime, limit: 0)
    change_column(:transfers, :created_at, :datetime, limit: 0)
    change_column(:transfers, :updated_at, :datetime, limit: 0)
    change_column(:deposits, :created_at, :datetime, limit: 0)
    change_column(:deposits, :updated_at, :datetime, limit: 0)
    change_column(:deposits, :completed_at, :datetime, limit: 0)
    change_column(:withdraws, :created_at, :datetime, limit: 0)
    change_column(:withdraws, :updated_at, :datetime, limit: 0)
    change_column(:withdraws, :completed_at, :datetime, limit: 0)
  end
end
