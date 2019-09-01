# encoding: UTF-8
# frozen_string_literal: true

module Operations
  class << self
    # TODO: Add specs for this function.
    def build_account_number(currency_id:, account_code:, member_uid: nil)
      [currency_id, account_code, member_uid].compact.join('-')
    end

    def split_account_number(account_number:)
      currency_id, code, member_uid = account_number.split('-')
      { currency_id: currency_id,
        code: code,
        member_uid: member_uid }
    end

    def klass_for(code:)
      "Operations::#{Operations::Account.find_by(code: code).type.capitalize}".constantize
    end

    def update_legacy_balance(liability)
      return unless liability.present? || liability.is_a?(Operations::Liability)

      account = liability.account
      legacy_account = liability.member.accounts.find_by(currency: liability.currency)

      credit = liability.credit
      debit = liability.debit

      if account.kind.main?
        if liability.credit.nonzero?
          legacy_account.plus_funds(credit)
        else
          legacy_account.sub_funds(debit)
        end
      elsif account.kind.locked?
        if credit.nonzero?
          legacy_account.plus_funds(credit)
          legacy_account.lock_funds(credit)
        else
          legacy_account.unlock_ans_sub_funds(debit)
        end
      end
    end
  end
end
