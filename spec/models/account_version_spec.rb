require 'spec_helper'

describe AccountVersion do

  let(:member)  { create(:member) }
  let(:account) { member.get_account(:btc) }

  before { account.update_attributes(locked: '10.0'.to_d, balance: '10.0'.to_d) }

  context "#optimistically_lock_account_and_save!" do
    # mock AccountVersion attributes of
    # `unlock_and_sub_funds('5.0'.to_d, locked: '8.0'.to_d, fee: ZERO)`
    let(:attrs) do
      { account_id: account.id,
        fun: :unlock_and_sub_funds,
        fee: Account::ZERO,
        reason: Account::UNKNOWN,
        amount: '15.0'.to_d,
        currency: account.currency,
        member_id: account.member_id,
        locked: '-8.0'.to_d,
        balance: '3.0'.to_d }
    end

    it "should require account id" do
      attrs.delete :account_id
      expect {
        AccountVersion.optimistically_lock_account_and_create!('13.0'.to_d, '2.0'.to_d, attrs)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it "should save record if associated account is fresh" do
      expect {
        # `unlock_and_sub_funds('5.0'.to_d, locked: '8.0'.to_d, fee: ZERO)`
        ActiveRecord::Base.connection.execute "update accounts set balance = balance + 3, locked = locked - 8 where id = #{account.id}"
        AccountVersion.optimistically_lock_account_and_create!('13.0'.to_d, '2.0'.to_d, attrs)
      }.to change(AccountVersion, :count).by(1)
    end

    it "should raise StaleObjectError if associated account is stale" do
      account_in_another_thread = Account.find account.id
      account_in_another_thread.plus_funds('2.0'.to_d)

      expect {
        # `unlock_and_sub_funds('5.0'.to_d, locked: '8.0'.to_d, fee: ZERO)`
        ActiveRecord::Base.connection.execute "update accounts set balance = balance + 3, locked = locked - 8 where id = #{account.id}"
        AccountVersion.optimistically_lock_account_and_create!('13.0'.to_d, '2.0'.to_d, attrs)
      }.to raise_error(ActiveRecord::StaleObjectError)

      expect {
        AccountVersion.optimistically_lock_account_and_create!('15.0'.to_d, '2.0'.to_d, attrs)
      }.to change(AccountVersion, :count).by(1)
    end

    it "should save associated modifiable record" do
      attrs_with_modifiable = attrs.merge(modifiable_id: 1, modifiable_type: 'OrderAsk')

      expect {
        AccountVersion.optimistically_lock_account_and_create!('10.0'.to_d, '10.0'.to_d, attrs_with_modifiable)
      }.to change(AccountVersion, :count).by(1)
    end
  end

end
