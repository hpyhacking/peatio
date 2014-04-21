require 'liability-proof'

namespace :solvency do

  desc "Clear old liability proofs"
  task :clean => :environment do
    Proof.where('created_at < ?', 1.week.ago).delete_all
    PartialTree.where('created_at < ?', 1.week.ago).delete_all
  end

  desc "Generate liability proof"
  task :liability_proof => :environment do
    Account.currency.values.each do |type|
      puts "\n*** Start #{type} liability proof generation ***"
      accounts = Account.with_currency(type).includes(:member)
      formatted_accounts = accounts.map do |account|
        { 'user'    => account.member.sn,
          'balance' => account.balance + account.locked }
      end

      tree = LiabilityProof::Tree.new formatted_accounts, currency: type.upcase

      puts "Generating root node .."
      sum   = tree.root_json['root']['sum']
      proof = Proof.create!(sum: sum, root: tree.root_json, currency: type)

      puts "Generating partial trees .."
      accounts.each do |acct|
        json = tree.partial_json(acct.member.sn)
        sum  = tree.last_user_node['sum']
        acct.partial_trees.create! sum: sum, proof: proof, json: tree.partial_json(acct.member.sn)
      end
      puts "#{accounts.size} partial trees generated."

      proof.ready!
    end

    puts "Complete."
  end

end
