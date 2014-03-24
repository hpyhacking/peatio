require 'liability-proof'

namespace :solvency do

  task :liability_proof => :environment do
    Account.currency.values.each do |type|
      puts "\n*** Start #{type} liability proof generation ***"
      accounts = Account.with_currency(type).includes(:member)
      formatted_accounts = accounts.map do |account|
        { 'user'    => account.member.sn,
          'balance' => account.balance }
      end

      tree = LiabilityProof::Tree.new formatted_accounts, currency: type.upcase

      puts "Generating root node .."
      proof = Proof.create!(root: tree.root_json, currency: type)

      puts "Generating partial trees .."
      accounts.each do |acct|
        acct.update_attributes(partial_tree: tree.partial_json(acct.member.sn))
      end
      puts "#{accounts.size} partial trees generated."

      proof.ready!
    end

    puts "Complete."
  end

end
