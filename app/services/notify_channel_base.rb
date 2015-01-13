class NotifyChannelBase
  attr_reader :klass, :notification_type, :payload

  def initialize(klass, notification_type, payload = {})
    @klass = klass
    @notification_type = notification_type
    @payload = @payload
  end

  def notify!
  end

  def self.name
  end
end
