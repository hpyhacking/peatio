class AdminsFeeder < AbstractFeeder
  def feed
    feeder = AdminFeeder.new

    ENV.fetch('ADMIN').split(',').map do |email|
      password = random_password
      admin    = feeder.feed(email, password)
      admin.define_singleton_method(:password) { password }
      admin
    end
  end

private

  def random_password
    Faker::Internet.password(8, 64)
  end
end
