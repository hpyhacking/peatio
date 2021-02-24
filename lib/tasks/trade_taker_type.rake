desc 'Select and update taker_type base on taker_order'
task assign_taker_type: :environment do
  Trade.where(taker_type: '').find_in_batches do |batch|
    ActiveRecord::Base.transaction do
      batch.each do |t|
        t.update_attribute(:taker_type, t.taker_order.side) if t.taker_order.present?
      end
    end
  end
end
