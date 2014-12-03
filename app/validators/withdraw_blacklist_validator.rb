class WithdrawBlacklistValidator < ActiveModel::Validator
  BLACK_LIST = YAML.load_file(Rails.root.join('config', 'withdraw_blacklist.yml'))

  def validate(record)
    if BLACK_LIST.keys.include?(record.currency) && BLACK_LIST[record.currency].include?(record.fund_uid)
      record.errors[:fund_uid] << I18n.t('withdraws.invalid_address')
    end
  end
end
