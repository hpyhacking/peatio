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

  describe '#payment_address' do
    it { expect(subject.payment_address).not_to be_nil }
    it { expect(subject.payment_address).to be_is_a(PaymentAddress) }
    context 'fiat currency' do
      subject { create_account(:usd).payment_address }
      it { is_expected.to be_nil }
    end
  end

  describe 'concurrent lock_funds' do
    it 'should raise error on the second lock_funds' do
      account1 = Account.find subject.id
      account2 = Account.find subject.id

      expect(subject.reload.balance).to eq BigDecimal.new('10')

      expect do
        ActiveRecord::Base.transaction do
          account1.lock_funds(8)
        end
        ActiveRecord::Base.transaction do
          account2.lock_funds(8)
        end
      end.to raise_error(Account::AccountError) { |e| expect(e.message).to eq 'Cannot lock funds (amount: 8).' }

      expect(subject.reload.balance).to eq BigDecimal.new('2')
    end
  end

  describe '.enabled' do
    before do
      create_account(:usd)
      create_account(:btc)
      create_account(:dash)
    end

    it 'returns the accounts with currency enabled' do
      currency = Currency.find(:dash)
      currency.transaction do
        currency.update_columns(enabled: false)
        expect(Account.enabled.count).to eq 21
        currency.update_columns(enabled: true)
      end
    end
  end

  describe '#payment_address!' do
    it 'returns the same payment address is address generation process is in progress' do
      expect(subject.payment_address!).to eq subject.payment_address
    end

    it 'return new payment address if previous has address generated' do
      subject.payment_address.tap do |previous|
        previous.update!(address: '1JSmYcCjBGm7RbjPppjZ1gGTDpBEmTGgGA')
        expect(subject.payment_address!).not_to eq previous
      end
    end
  end
end
