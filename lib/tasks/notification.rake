namespace :notification do
  desc "Add the default Notification channels to members."
  task init: :environment do
    Member.find_each do |member|
      EmailChannel::SUPORT_NOTIFY_TYPE.each do |snt|
        member.email_channels.create(notify_type: snt) unless member.email_channels.with_notify_type(snt).any?
      end

      SmsChannel::SUPORT_NOTIFY_TYPE.each do |snt|
        member.sms_channels.create(notify_type: snt) unless member.sms_channels.with_notify_type(snt).any?
      end
    end
  end
end
