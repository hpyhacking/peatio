class RemoveFieldsFromCurrenices < ActiveRecord::Migration
  class Ccy < ActiveRecord::Base
    serialize :options, JSON
    self.table_name = 'currencies'
    self.inheritance_column = :disabled
  end

  def change
    Ccy.where(type: :coin).find_each do |ccy|
      ccy.update_columns \
      options: ccy.options.except('supports_hd_protocol', 'allow_multiple_deposit_addresses')
    end
  end
end
