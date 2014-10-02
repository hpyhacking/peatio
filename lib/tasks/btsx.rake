namespace :btsx do

  task :deposit => %w(environment) do
    pts_id = Currency.find_by_code('pts').id
    versions = AccountVersion.find_by_sql <<-SQL
      SELECT * FROM account_versions WHERE id IN
      ( SELECT max(id) FROM account_versions WHERE created_at < '2014-03-01' AND currency = "#{pts_id}" GROUP BY account_id )
    SQL

    puts "Will deposit #{versions.map(&:amount).sum * 500} BTSX for #{versions.size} members, press Y to continue..."

    if STDIN.gets.chomp == 'Y'
      puts '*' * 80

      total = 0
      versions.each do |v|
        m = v.account.member
        acc = m.ac('btsx')
        amount = v.amount * 500

        #puts "plus funds #{amount} for account##{acc.id}"
        #acc.plus_funds amount, reason: Account::DEPOSIT
        #m.deposits.create account: acc, currency: 'btsx', amount: amount, fund_uid: 'pts', fund_extra: 'snapshot', txid: "yunbi#{acc.id}"
        puts "#{m.id} #{m.display_name} #{m.email} #{v.amount} #{amount} #{acc.id}"

        total += amount
      end

      puts '*' * 80
      puts "TOTAL: Deposit #{total} BTSX for #{versions.size} members"
    else
      puts 'Skipped'
    end
  end

end
