class ChangeFundExtraValueToBankCode < ActiveRecord::Migration
  def up
    hash = banks.invert
    FundSource.all.each do |record|
      record.update_column :extra, hash[record.extra] if hash[record.extra]
    end

    Withdraw.all.each do |record|
      record.update_column :fund_extra, hash[record.fund_extra] if hash[record.fund_extra]
    end

    Deposit.all.each do |record|
      record.update_column :fund_extra, hash[record.fund_extra] if hash[record.fund_extra]
    end
  end

  def down
    hash = banks
    FundSource.all.each do |record|
      record.update_column :extra, hash[record.extra] if hash[record.extra]
    end

    Withdraw.all.each do |record|
      record.update_column :fund_extra, hash[record.fund_extra] if hash[record.fund_extra]
    end
  end


  private

  def banks
    {"icbc"=>"工商银行",
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
    "gdb"=>"广东发展银行"}
  end

  class Deposits::Bank
    def fund_extra
      results = ActiveRecord::Base.connection.exec_query "select fund_extra from #{self.class.table_name} where id = #{id}"
      results[0].try(:[], 'fund_extra')
    end
  end

  class Withdraw < ActiveRecord::Base
  end
  class FundSource < ActiveRecord::Base
  end
end
