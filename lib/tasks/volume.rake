namespace :volume do
  desc "generate real trade volume"
  task build: :environment do
    daily = Member.find_by_email('foo@peatio.dev').trades.
      where('ask_member_id <> bid_member_id').
      group_by{|t| t.created_at.to_date}

    daily.each do |date, trades|
      puts "#{date.to_s}: #{trades.sum(&:volume).to_f.round(2)}"
    end
  end
end
