class CreateNotificationChannels < ActiveRecord::Migration
  def change
    create_table :notification_channels do |t|
      t.integer :member_id
      t.string :notify_type
      t.string :type
    end
  end
end
