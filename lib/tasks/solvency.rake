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
        { 'user'    => account.member.email,
          'balance' => account.balance + account.locked }
      end

      next if formatted_accounts.empty?

      tree = LiabilityProof::Tree.new formatted_accounts, currency: type.upcase

      puts "Generating root node .."
      sum   = tree.root_json['root']['sum']
      proof = Proof.create!(sum: sum, root: tree.root_json, currency: type)

      puts "Generating partial trees .."
      accounts.each do |acct|
        json = tree.partial_json(acct.member.email)
        sum  = tree.last_user_node['sum']
        acct.partial_trees.create! sum: sum, proof: proof, json: tree.partial_json(acct.member.email)
      end
      puts "#{accounts.size} partial trees generated."

      if proof.coin?
        puts "\n*** Fetching #{type} total assets ***"
        addresses = Currency.assets('btc')['accounts'].map do |account|
          account['address']
        end.join(',')

        begin
          doc = open "http://#{type}.blockr.io/api/v1/address/balance/" << addresses, redirect: false
          proof.addresses = [JSON.parse(doc.read)['data']].flatten
          puts "address balances fetched."
        rescue OpenURI::HTTPRedirect => e
          proof.addresses = []
          puts "#{type} is not supported by blockr.io yet. Unable to fetch address balances automatically."
        end
      end

      proof.ready!
    end

    puts "Complete."
  end

end
