class NotificationService
  SUPPORT_NOTIFY_CHANNELS = [EmailNotifyChannel]
  #SUPPORT_NOTIFY_CHANNELS = [EmailNotifyChannel, SmsNotifyChannel]

  attr_reader :channels

  def initialize(member, notification_type, payload = {}, klass = "Member")
    @channels = []
    SUPPORT_NOTIFY_CHANNELS.each do |nc|
      @channels << nc.new(member, klass, notification_type, payload)
    end
  end

  def notify!
    @channels.each do |channel|
      channel.notify! if channel.notifyable? && channel.notify?
    end
  end

end

