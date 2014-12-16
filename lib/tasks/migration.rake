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

  desc "update ask_member_id and bid_member_id of trades"
  task update_ask_member_id_and_bid_member_id_of_trades: :environment do
    Trade.find_each do |trade|
      trade.update \
        ask_member_id: trade.ask.try(:member_id),
        bid_member_id: trade.bid.try(:member_id)
    end
  end

  desc "set history orders ord_type to limit"
  task fix_orders_without_ord_type_and_locked: :environment do
    Order.find_each do |order|
      if order.ord_type.blank?
        order.ord_type = 'limit'
      end

      if order.ord_type == 'limit'
        order.origin_locked = order.price*order.origin_volume
        order.locked = order.compute_locked
      end

      order.save! if order.changed?
    end
  end

  desc "fill funds_received of history orders"
  task fill_funds_received: :environment do
    OrderBid.where(funds_received: 0).update_all('funds_received = origin_volume - volume')

    total = OrderAsk.where(funds_received: 0).count
    count = 0
    OrderAsk.where(funds_received: 0).find_each do |order|
      count += 1
      funds = order.trades.sum(:funds)
      order.update_columns funds_received: funds if funds > ::Trade::ZERO
      puts "[#{count}/#{total}] filled #{funds} for ask##{order.id}"
    end
  end

  desc "reset aasm_state of id_documents"
  task reset_aasm_state_of_id_documents: :environment do
    IdDocument.find_each do |id_doc|
      if id_doc.verified
        id_doc.update aasm_state: 'verified'
      else
        id_doc.update aasm_state: 'unverified'
      end
    end
  end

  desc "upgrade to new deposit-transaction schema"
  task new_deposit_transaction_schema: :environment do
    PaymentTransaction.where(type: nil).update_all(type: 'PaymentTransaction::Normal')
    PaymentTransaction.where(type: 'PaymentTransaction::Default').update_all(type: 'PaymentTransaction::Normal')

    PaymentTransaction::Normal.find_each do |pt|
      pt.update_attributes txout: 0
    end

    Deposit.find_each do |deposit|
      if deposit.payment_transaction_id.nil?
        pt = PaymentTransaction.find_by_txid deposit.txid
        deposit.update_attributes(payment_transaction_id: pt.id, txout: pt.txout) if pt
      end
    end
  end

  desc "fix scopes of old api tokens"
  task fix_scopes: :environment do
    puts APIToken.where(scopes: nil).update_all(scopes: 'all')
  end

  desc "fix order trades_count"
  task fix_trades_count: :environment do
    orders = Order.where('origin_volume != volume AND trades_count = 0')
    total = orders.count
    count = 0

    puts "Found #{total} matched orders, start processing:"
    orders.find_each do |order|
      count += 1
      print "#{count}/#{total} processing Order##{order.id} ..."
      order.update_column :trades_count, order.trades.count
      puts " #{order.trades_count} trades."
    end
  end

end
