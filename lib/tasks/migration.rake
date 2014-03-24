namespace :migration do
  desc "set member activation from identity"
  task set_member_activation: :environment do
    Identity.all.each do |i|
      m = Member.find_by_email(i.email)
      m.update_column(:activated, i.is_active?) if m
      puts "ERROR #{i.email}" unless m
      puts "updated #{i.email} acivation to #{i.is_active?}"
    end
  end

  desc "build auth to exist identites"
  task build_auth_to_exist_identites: :environment do
    Identity.all.each do |i|
      Authentication.create uid: i.id, provider: 'identity'
    end
  end

  desc "migrate fund sources"
  task build_fund_sources: :environment do
    if ActiveRecord::Migrator.current_version == 20140324060148
      puts "BEGIN ------------------------------------------"
      FundSource.with_deleted.all.each do |f|
        suppress(Exception) do
          a = Account.find(f.account_id)
          f.update_columns(member_id: a.member_id, currency: a.currency_value)
        end
      end
      puts "END --------------------------------------------"
    end
  end
end
