# encoding: UTF-8
# frozen_string_literal: true

describe Account do
  subject { create_account(:btc, balance: '10.0'.to_d, locked: '10.0'.to_d) }

  it { expect(subject.amount).to be_d '20' }
  it { expect(subject.sub_funds('1.0'.to_d).balance).to eql '9.0'.to_d }
  it { expect(subject.plus_funds('1.0'.to_d).balance).to eql '11.0'.to_d }
  it { expect(subject.unlock_funds('1.0'.to_d).locked).to eql '9.0'.to_d }
  it { expect(subject.unlock_funds('1.0'.to_d).balance).to eql '11.0'.to_d }
  it { expect(subject.lock_funds('1.0'.to_d).locked).to eql '11.0'.to_d }
  it { expect(subject.lock_funds('1.0'.to_d).balance).to eql '9.0'.to_d }

  it { expect(subject.unlock_and_sub_funds('1.0'.to_d).balance).to be_d '10' }
  it { expect(subject.unlock_and_sub_funds('1.0'.to_d).locked).to be_d '9' }

  it { expect(subject.sub_funds('0.1'.to_d).balance).to eql '9.9'.to_d }
  it { expect(subject.plus_funds('0.1'.to_d).balance).to eql '10.1'.to_d }
  it { expect(subject.unlock_funds('0.1'.to_d).locked).to eql '9.9'.to_d }
  it { expect(subject.unlock_funds('0.1'.to_d).balance).to eql '10.1'.to_d }
  it { expect(subject.lock_funds('0.1'.to_d).locked).to eql '10.1'.to_d }
  it { expect(subject.lock_funds('0.1'.to_d).balance).to eql '9.9'.to_d }

  it { expect(subject.sub_funds('10.0'.to_d).balance).to eql '0.0'.to_d }
  it { expect(subject.plus_funds('10.0'.to_d).balance).to eql '20.0'.to_d }
  it { expect(subject.unlock_funds('10.0'.to_d).locked).to eql '0.0'.to_d }
  it { expect(subject.unlock_funds('10.0'.to_d).balance).to eql '20.0'.to_d }
  it { expect(subject.lock_funds('10.0'.to_d).locked).to eql '20.0'.to_d }
  it { expect(subject.lock_funds('10.0'.to_d).balance).to eql '0.0'.to_d }

  it { expect { subject.sub_funds('11.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.lock_funds('11.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.unlock_funds('11.0'.to_d) }.to raise_error(Account::AccountError) }

  it { expect { subject.sub_funds('-1.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.plus_funds('-1.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.lock_funds('-1.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.unlock_funds('-1.0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.sub_funds('0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.plus_funds('0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.lock_funds('0'.to_d) }.to raise_error(Account::AccountError) }
  it { expect { subject.unlock_funds('0'.to_d) }.to raise_error(Account::AccountError) }

  describe 'double operation' do
    let(:strike_volume) { '10.0'.to_d }
    let(:account) { create_account }

    it 'expect double operation funds' do
      expect do
        account.plus_funds(strike_volume)
        account.sub_funds(strike_volume)
      end.to_not(change { account.balance })
    end
  end

  describe 'concurrent lock_funds' do
    it 'should raise error on the second lock_funds' do
      account1 = Account.find subject.id
      account2 = Account.find subject.id

      expect(subject.reload.balance).to eq 10.to_d

      expect do
        ActiveRecord::Base.transaction do
          account1.lock_funds(8)
        end
        ActiveRecord::Base.transaction do
          account2.lock_funds(8)
        end
      end.to raise_error(Account::AccountError) { |e| expect(e.message).to eq "Cannot lock funds (member id: #{subject.member_id}, currency id: #{subject.currency_id}, amount: 8, balance: 2.0, locked: 18.0)." }

      expect(subject.reload.balance).to eq 2.to_d
    end
  end

  describe '.visible' do
    before do
      create_account(:usd)
      create_account(:btc)
      create_account(:eth)
    end

    it 'returns the accounts with currency visible' do
      currency = Currency.find(:eth)
      currency.transaction do
        # We have created 3 account.
        expect{ currency.update_columns(status: :disabled) }.to change { Account.visible.count }.by(-1)
        currency.update_columns(status: :enabled)
      end
    end
  end
end
