namespace :solvency do
  desc 'Clear old liability proofs'
  task clean: :environment do
    Proof.where('created_at < ?', 1.week.ago).delete_all
    PartialTree.where('created_at < ?', 1.week.ago).delete_all
  end

  desc 'Generate liability proof'
  task liability_proof: :environment do
    logger = Logger.new(STDOUT)

    Currency.find_each do |ccy|
      logger.info "*** Starting #{ccy.code.upcase} liability proof generation ***"
      accounts = Account.with_currency(ccy).includes(:member)
      formatted_accounts = accounts.map do |account|
        {
          'user' => account.member.email,
          'balance' => account.balance + account.locked
        }
      end

      if formatted_accounts.empty?
        logger.warn("No accounts using #{ccy.code.upcase}. Skipping")
        next
      end

      tree = LiabilityProof::Tree.new(formatted_accounts, currency: ccy.code)

      logger.info 'Generating root node...'
      sum = tree.root_json['root']['sum']
      proof = Proof.create!(
        sum: sum,
        root: tree.root_json,
        currency: ccy
      )
      logger.info 'Root node generated.'

      logger.info 'Generating partial trees...'
      accounts.each do |acct|
        json = tree.partial_json(acct.member.email)
        sum = tree.last_user_node['sum']
        acct.partial_trees.create!(
          sum: sum,
          proof: proof,
          json: json
        )
      end
      logger.info "#{accounts.size} partial trees generated."

      if proof.coin?
        logger.info "Fetching #{ccy.code.upcase} total assets..."
        # addresses = Currency.assets(type)['accounts']
        #                     .map { |a| a['address'] }.join(',')

        # TODO: Fix following warning (blockr.io seems deprecated):
        logger.warn 'Fetching accounts balances is not implemented yet'
        proof.addresses = []
      end

      proof.ready!
    end

    logger.info 'Liability proofs generated.'
  end
end
