class NotificationChannel < ActiveRecord::Base
  attr_reader :name, :payload

  belongs_to :member

  def notify!(name, payload = {})
  end

  def notifyable?
    false
  end

  def notify?(name)
    !!self.try(name)
  end
end
