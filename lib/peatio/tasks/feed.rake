namespace :peatio do
  task feed: :environment do
    members = []

    def random_email
      Faker::Internet.email
    end

    def random_password
      Faker::Internet.password(8, 64)
    end

    MemberFeeder.new.tap do |feeder|
      10.times do
        email, password = random_email, random_password
        feeder.feed(email, password)
        members << { email: email, password: password }
      end
    end

    AdminFeeder.new.tap do |feeder|
      ENV.fetch('ADMIN').split(',').each do |email|
        password = random_password
        feeder.feed(email, password)
        members << { email: email, password: password, admin: true }
      end
    end

    longest_email = members.map { |m| m[:email] }.sort_by(&:length).last
    members.each do |member|
      Rails.logger << "#{member[:admin] ? 'ADMIN ' : 'MEMBER'} #{member[:email].ljust(longest_email.length)} #{member[:password]}\n"
    end
  end
end
