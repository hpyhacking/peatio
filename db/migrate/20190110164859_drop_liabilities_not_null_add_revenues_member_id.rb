class DropLiabilitiesNotNullAddRevenuesMemberId < ActiveRecord::Migration
  def change
    change_column_null(:liabilities, :member_id, true)

    add_column(:revenues, :member_id, :integer,
               index: true, null: true, after: :currency_id)
  end
end
