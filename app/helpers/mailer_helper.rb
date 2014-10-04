module MailerHelper
  def working_time?(time=Time.now.hour)
    hour = time.hour
    hour >= 9 and hour <= 18
  end
end
