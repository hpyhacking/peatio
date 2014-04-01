namespace :config do
  desc "Intialize new currency account after new currenecy added to currencies.yml"
  task :create_new_account => [:environment] do
    Currency.codes.map do |key, code|
      unless Account.where(currency: code).first
        puts "Create new accounts for #{key} .."
        Member.all.each do |m|
          m.accounts.create currency: code, balance: 0, locked: 0
        end
      end
    end
  end
end
