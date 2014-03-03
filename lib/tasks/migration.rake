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
end
