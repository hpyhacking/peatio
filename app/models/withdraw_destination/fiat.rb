class WithdrawDestination
  class Fiat < self
    nested_attr :bank_name,
                :bank_branch_name,
                :bank_branch_address,
                :bank_identifier_code,
                :bank_account_number,
                :bank_account_holder_name

    validates :bank_name, :bank_account_number, :bank_branch_name, :bank_identifier_code, :bank_branch_address, :bank_account_holder_name, presence: true

    def dummy
      self.label = 'dummy'
      self.class.fields.keys.each { |field| send(field.to_s + '=', 'dummy') }
      self
    end

    class << self
      def fields
        super.merge! \
          bank_name:                'The bank name.',
          bank_branch_name:         'The bank branch name.',
          bank_branch_address:      'The place where the bank branch is located.',
          bank_identifier_code:     'Financial institution\'s unique SWIFT/BIC code.',
          bank_account_number:      'International or SWIFT bank account number.',
          bank_account_holder_name: 'The name on your bank account.'
      end
    end
  end
end

# == Schema Information
# Schema version: 20180305111648
#
# Table name: withdraw_destinations
#
#  id          :integer          not null, primary key
#  type        :string(30)       not null
#  member_id   :integer          not null
#  currency_id :integer          not null
#  details     :string(4096)     default({}), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_withdraw_destinations_on_currency_id  (currency_id)
#  index_withdraw_destinations_on_member_id    (member_id)
#  index_withdraw_destinations_on_type         (type)
#
