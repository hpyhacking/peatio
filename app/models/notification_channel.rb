class NotificationChannel < ActiveRecord::Base
  attr_reader :payload
  NOTIFY_TYPE = %w[ notify_signin reset_password_done google_auth_activated google_auth_deactivated sms_auth_activated
                    sms_auth_deactivated phone_number_verified deposit_accepted withdraw_submitted
                    withdraw_processing withdraw_done withdraw_state ]

  SUPORT_NOTIFY_TYPE = NOTIFY_TYPE
  extend Enumerize
  enumerize :notify_type, in: NOTIFY_TYPE, scope: true

  belongs_to :member

  def notify!(payload = {})
  end

  def notifyable?
    false
  end

  def name
    self.notify_type
  end
end
