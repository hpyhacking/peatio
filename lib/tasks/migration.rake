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

  desc "Change bank name in withdraws and fund_sources to bank code"
  task convert_to_bank_code: :environment do
    banks = {
      "icbc"=>"工商银行",
      "cbc"=>"中国建设银行",
      "bc"=>"中国银行",
      "bcm"=>"交通银行",
      "abc"=>"中国农业银行",
      "cmb"=>"招商银行",
      "cmbc"=>"民生银行",
      "cncb"=>"中信银行",
      "hxb"=>"华夏银行",
      "cib"=>"兴业银行",
      "spdb"=>"上海浦东发展银行",
      "bob"=>"北京银行",
      "ceb"=>"中国光大银行",
      "sdb"=>"深圳发展银行",
      "gdb"=>"广东发展银行"}.invert

      Withdraws::Bank.class_eval do
        def fund_extra
          results = ActiveRecord::Base.connection.exec_query "select fund_extra from #{self.class.table_name} where id = #{id}"
          results[0].try(:[], 'fund_extra')
        end
      end

      FundSource.all.each do |record|
        record.update_column :extra, banks[record.extra] if banks[record.extra]
      end

      Withdraws::Bank.all.each do |record|
        record.update_column :fund_extra, banks[record.fund_extra] if banks[record.fund_extra]
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
  task set_history_ord_type: :environment do
    Order.find_each do |order|
      order.ord_type = 'limit' if order.ord_type.blank?
      order.save
    end
  end

  desc "set locked and origin_locked on limit orders"
  task set_order_locked: :environment do
    Order.find_each do |order|
      if order.ord_type == 'limit'
        order.origin_locked = order.price*order.origin_volume
        order.locked = order.compute_locked
        order.save
      end
    end
  end
end
