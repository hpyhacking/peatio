# encoding: UTF-8
# frozen_string_literal: true

class MembersFeeder < AbstractFeeder
  def feed(n = 10)
    feeder = MemberFeeder.new
    n.times.map { feeder.feed(random_email) }
  end

private

  def random_email
    Faker::Internet.email
  end
end
