class MembersFeeder < AbstractFeeder
  def feed(n = 10)
    feeder = MemberFeeder.new

    n.times.map do
      email, password = random_email, random_password
      member          = feeder.feed(email, password)
      member.define_singleton_method(:password) { password }
      member
    end
  end

private

  def random_email
    Faker::Internet.email
  end

  def random_password
    Faker::Internet.password(8, 64)
  end
end
