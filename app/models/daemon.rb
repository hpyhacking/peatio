class Daemon
  def self.statuses
    Rails.cache.fetch('daemon_statuses', expires_in: 3.minute) do
      Daemons::Rails::Monitoring.statuses
    end
  end
end
