class CreateNotificationChannels < ActiveRecord::Migration
  def change
    create_table :notification_channels do |t|
      t.integer :member_id
      t.boolean :notify_signin, default: true
      t.boolean :reset_password_done, default: true
      t.boolean :google_auth_activated, default: true
      t.boolean :google_auth_deactivated, default: true
      t.boolean :sms_auth_activated, default: true
      t.boolean :sms_auth_deactivated, default: true
      t.boolean :phone_number_verified, default: true

      # Deposit
      t.boolean :deposit_accepted, default: true

      # Withdraw
      t.boolean :withdraw_submitted, default: true
      t.boolean :withdraw_processing, default: true
      t.boolean :withdraw_done, default: true
      t.boolean :withdraw_state, default: true
      t.string :type
    end
  end
end
