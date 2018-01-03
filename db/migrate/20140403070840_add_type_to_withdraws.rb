class AddTypeToWithdraws < ActiveRecord::Migration
  def up
    add_column :withdraws, :type, :string

    Withdraw.all.each do |withdraw|
      type = case withdraw.currency
             when 'btc'
               'Withdraws::Satoshi'
             when 'xrp'
               'Withdraws::Ripple'
             else
               'Withdraws::Bank'
             end
      withdraw.update_column :type, type
    end
  end

  def down
    remove_column :withdraws, :type
  end
end
