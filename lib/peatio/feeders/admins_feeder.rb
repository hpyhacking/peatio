class AdminsFeeder < AbstractFeeder
  def feed
    feeder = AdminFeeder.new
    ENV.fetch('ADMIN').split(',').map { |email| feeder.feed(email) }
  end
end
