class WithdrawBlacklistValidator < ActiveModel::Validator

  def validate(record)
    if blacklist.keys.include?(record.currency) && blacklist[record.currency].include?(record.fund_uid)
      record.errors[:fund_uid] << I18n.t('withdraws.invalid_address')
    end
  end

  private

  def blacklist
    if @blacklist.nil?
      @blacklist = {}
      withdraw_channels= YAML.load_file(Rails.root.join('config', 'withdraw_channels.yml'))
      withdraw_channels.select{|c| c["blacklist"]}.each do |wc|
        @blacklist[wc["currency"]] = wc["blacklist"]
      end
    end
    @blacklist
  end
end
