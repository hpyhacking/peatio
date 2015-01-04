class NotifyChannelBase
  attr_reader :member, :klass, :notification_type, :payload

  def initialize(member, klass, notification_type, payload = {})
    @member = member
    @klass = klass
    @notification_type = notification_type
    @payload = @payload
  end

  def notifyable?
  end

  def notify?
    # Check if this notification_type need to be triggered.
    # In the future we can support user notify configuration.
    true
  end

  def notify!
  end
end
