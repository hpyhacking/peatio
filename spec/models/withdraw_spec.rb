# encoding: UTF-8
# frozen_string_literal: true

describe Withdraw do
  context 'aasm_state' do
    subject { create(:usd_withdraw, :with_deposit_liability, sum: 1000) }

    before do
      subject.stubs(:send_withdraw_confirm_email)
    end

    it 'initializes with state :prepared' do
      expect(subject.prepared?).to be true
    end

    it 'transitions to :rejected after calling #reject!' do
      subject.accept!
      subject.reject!

      expect(subject.rejected?).to be true
    end

    context :accept do
      it 'transitions to :submitted after calling #accept!' do
        subject.accept!
        expect(subject.accepted?).to be true
        expect(subject.sum).to eq subject.account.locked
      end

      context :record_submit_operations! do
        it 'creates two liability operations' do
          expect{ subject.accept! }.to change{ Operations::Liability.count }.by(2)
        end

        it 'doesn\'t create asset operations' do
          expect{ subject.accept! }.to_not change{ Operations::Asset.count }
        end

        it 'debits main liabilities for member' do
          expect{ subject.accept! }.to change {
            subject.member.balance_for(currency: subject.currency, kind: :main)
          }.by(-subject.sum)
        end

        it 'credits locked liabilities for member' do
          expect{ subject.accept! }.to change {
            subject.member.balance_for(currency: subject.currency, kind: :locked)
          }.by(subject.sum)
        end

        it 'updates both legacy and operations based member balance' do
          subject.accept!

          %i[main locked].each do |kind|
            expect(
              subject.member.balance_for(currency: subject.currency, kind: kind)
            ).to eq(
              subject.member.legacy_balance_for(currency: subject.currency, kind: kind)
            )
          end
        end
      end
    end

    context :process do
      before { subject.accept! }
      before { subject.accept! }

      it 'transitions to :processing after calling #process! when withdrawing fiat currency' do
        subject.currency.stubs(:coin?).returns(false)

        subject.process!

        expect(subject.processing?).to be true
      end

      it 'transitions to :failed after calling #fail! when withdrawing fiat currency' do
        subject.currency.stubs(:coin?).returns(false)

        subject.process!

        expect { subject.fail! }.to_not change { subject.account.amount }

        expect(subject.failed?).to be true
      end

      it 'transitions to :processing after calling #process!' do
        subject.expects(:send_coins!)

        subject.process!

        expect(subject.processing?).to be true
      end

      it 'transitions to :processing after calling #process from :skipped' do
        subject.process!
        expect(subject.processing?).to be true

        subject.skip!
        expect(subject.skipped?).to be true

        subject.process!
        expect(subject.processing?).to be true
      end

      it 'transitions to :errored after calling #err from :processing' do
        subject.process!
        expect(subject.processing?).to be true

        expect { subject.err! StandardError.new }.to_not change { subject.account.amount }
        expect(subject.errored?).to be true

        subject.process!
        expect(subject.processing?).to be true
      end
    end

    context :cancel do
      it 'transitions to :canceled after calling #cancel!' do
        subject.cancel!

        expect(subject.canceled?).to be true
      end

      it 'transitions from :submitted to :canceled after calling #cancel!' do
        subject.accept!
        subject.cancel!

        expect(subject.canceled?).to be true
      end

      it 'transitions from :accepted to :canceled after calling #cancel!' do
        subject.accept!
        subject.accept!
        subject.cancel!

        expect(subject.canceled?).to be true
      end

      context :record_cancel_operations do
        before do
          subject.accept!
          subject.accept!
        end
        it 'creates two liability operations' do
          expect{ subject.cancel! }.to change{ Operations::Liability.count }.by(2)
        end

        it 'doesn\'t create asset operations' do
          expect{ subject.cancel! }.to_not change{ Operations::Asset.count }
        end

        it 'credits main liabilities for member' do
          expect{ subject.cancel! }.to change {
            subject.member.balance_for(currency: subject.currency, kind: :main)
          }.by(subject.sum)
        end

        it 'debits locked liabilities for member' do
          expect{ subject.cancel! }.to change {
            subject.member.balance_for(currency: subject.currency, kind: :locked)
          }.by(-subject.sum)
        end

        it 'updates both legacy and operations based member balance' do
          subject.cancel!

          %i[main locked].each do |kind|
            expect(
              subject.member.balance_for(currency: subject.currency, kind: kind)
            ).to eq(
              subject.member.legacy_balance_for(currency: subject.currency, kind: kind)
            )
          end
        end
      end
    end

    context :skip do
      before do
        subject.accept!
        subject.accept!
        subject.process!
      end

      it 'transitions from :accept to :skipped after calling #process' do
        subject.skip!

        expect(subject.skipped?).to be true
      end
    end

    context :reject do
      before do
        subject.accept!
      end

      it 'transitions from :submitted to :rejected after calling #reject!' do
        subject.reject!
        expect(subject.rejected?).to be true
      end

      it 'transitions from :accepted to :rejected after calling #reject!' do
        subject.accept!
        subject.reject!

        expect(subject.rejected?).to be true
      end

      it 'transitions from :under_review to :rejected after calling #reject!' do
        subject.process!
        subject.review!
        subject.reject!

        expect(subject.rejected?).to be true
      end

      context 'from to_rejected' do
        before do
          subject.update(aasm_state: :to_reject)
        end

        it 'transitions from :accepted to :rejected after calling #reject!' do
          subject.reject!

          expect(subject.rejected?).to be true
        end
      end

      context :record_cancel_operations do

        it 'creates two liability operations' do
          expect{ subject.reject! }.to change{ Operations::Liability.count }.by(2)
        end

        it 'doesn\'t create asset operations' do
          expect{ subject.reject! }.to_not change{ Operations::Asset.count }
        end

        it 'credits main liabilities for member' do
          expect{ subject.reject! }.to change {
            subject.member.balance_for(currency: subject.currency, kind: :main)
          }.by(subject.sum)
        end

        it 'debits locked liabilities for member' do
          expect{ subject.reject! }.to change {
            subject.member.balance_for(currency: subject.currency, kind: :locked)
          }.by(-subject.sum)
        end

        it 'updates both legacy and operations based member balance' do
          subject.reject!

          %i[main locked].each do |kind|
            expect(
              subject.member.balance_for(currency: subject.currency, kind: kind)
            ).to eq(
              subject.member.legacy_balance_for(currency: subject.currency, kind: kind)
            )
          end
        end
      end
    end

    context :success do

      before do
        subject.accept!
        subject.accept!
        subject.process!
        subject.dispatch!
      end

      it 'transitions from :confirming to :success after calling #success!' do
        subject.success!

        expect(subject.succeed?).to be true
      end

      it 'transitions from :under_review to :success after calling #success!' do
        subject.accept!
        subject.process!
        subject.review!
        subject.success!

        expect(subject.succeed?).to be true
      end

      context :record_complete_operations do

        it 'creates single liability operation' do
          expect{ subject.success! }.to change{ Operations::Liability.count }.by(1)
        end

        it 'creates asset operation' do
          expect{ subject.success! }.to change{ Operations::Asset.count }.by(1)
        end

        it 'doesn\'t change main liability balance for member' do
          expect{ subject.success! }.to_not change {
            subject.member.balance_for(currency: subject.currency, kind: :main)
          }
        end

        it 'debits locked liabilities for member' do
          expect{ subject.success! }.to change {
            subject.member.balance_for(currency: subject.currency, kind: :locked)
          }.by(-subject.sum)
        end

        it 'updates both legacy and operations based member balance' do
          subject.success!

          %i[main locked].each do |kind|
            expect(
              subject.member.balance_for(currency: subject.currency, kind: kind)
            ).to eq(
              subject.member.legacy_balance_for(currency: subject.currency, kind: kind)
            )
          end
        end

        it 'credits revenues' do
          expect{ subject.success! }.to change {
            Operations::Revenue.balance(currency: subject.currency)
          }.by(subject.fee)
        end

        it 'creates revenue operation from member' do
          expect{ subject.success! }.to change {
            Operations::Revenue.where(member: subject.member).count
          }.by(1)
        end
      end
    end
    context :load do
      let(:txid) { 'a738cb8411e2141f3de43c5f3e7a3aabe71c099bb91d296ded84f0daf29d881c' }

      subject { create(:btc_withdraw, :with_deposit_liability) }

      before { subject.accept! }

      it 'doesn\'t change state after calling #load! when withdrawing coin currency' do
        subject.load!
        expect(subject.accepted?).to be true
      end

      it 'transitions to :confirming after calling #load! when withdrawing coin currency' do
        BlockchainService.any_instance.expects(:fetch_transaction).once.returns(Peatio::Transaction.new)
        subject.update(txid: txid)
        subject.load!
        expect(subject.confirming?).to be true
      end
    end

    context :load do
      let(:txid) { 'a738cb8411e2141f3de43c5f3e7a3aabe71c099bb91d296ded84f0daf29d881c' }

      subject { create(:btc_withdraw, :with_deposit_liability) }

      before { subject.accept! }
      before { subject.accept! }

      it 'doesn\'t change state after calling #load! when withdrawing coin currency' do
        subject.load!
        expect(subject.accepted?).to be true
      end

      it 'transitions to :confirming after calling #load! when withdrawing coin currency' do
        BlockchainService.any_instance.expects(:fetch_transaction).once.returns(Peatio::Transaction.new)
        subject.update(txid: txid)
        subject.load!
        expect(subject.confirming?).to be true
      end
    end

    context :fail do
      subject { create(:btc_withdraw, :with_deposit_liability) }
      let!(:transaction) { Transaction.create(txid: subject.txid, reference: subject, kind: 'tx', from_address: 'fake_address', to_address: subject.rid, blockchain_key: subject.blockchain_key, status: :pending, currency_id: subject.currency_id) }

      before { subject.accept! }
      before { subject.accept! }

      context 'from errored' do
        before do
          subject.update!(aasm_state: :processing)
          subject.err!(Peatio::Wallet::ClientError.new('Something wrong with request'))
        end

        it do
          subject.fail!
          expect(subject.failed?).to be true
        end
      end

      context 'from skipped' do
        before do
          subject.update!(aasm_state: :skipped)
        end

        it do
          subject.fail!
          expect(subject.failed?).to be true
        end
      end

      context 'from under_review' do
        before do
          subject.update!(aasm_state: :under_review)
        end

        it do
          subject.fail!
          expect(subject.failed?).to be true
        end
      end

      context 'with archived beneficiary' do
        let(:member) { create(:member) }
        let(:address) { Faker::Blockchain::Ethereum.address }
        let(:coin) { Currency.find(:btc) }

        subject { create(:btc_withdraw, :with_deposit_liability, member: member, rid: address, beneficiary: beneficiary) }

        before { subject.accept! }
        before { subject.accept! }

        let!(:beneficiary) { create(:beneficiary,
                                    member: member,
                                    currency: coin,
                                    state: :active,
                                    data: generate(:coin_beneficiary_data).merge(address: address)) }

        before do
          subject.update!(aasm_state: :processing)
          subject.err!(Peatio::Wallet::ClientError.new('Something wrong with request'))
          beneficiary.update!(state: :archived)
        end
        it do
          subject.fail!
          expect(subject.failed?).to be true
        end
      end
    end

    context :review do
      before do
        subject.accept!
      end

      it 'transitions from :processing to :under_review after calling #review!' do
        subject.process!
        subject.review!


        expect(subject.under_review?).to be true
      end
    end
  end

  context 'fee is set to fixed value of 10' do
    let(:withdraw) { create(:usd_withdraw, :with_deposit_liability, sum: 200) }
    before { BlockchainCurrency.any_instance.expects(:withdraw_fee).once.returns(10) }
    it 'computes fee' do
      expect(withdraw.fee).to eql 10.to_d
      expect(withdraw.amount).to eql 190.to_d
    end
  end

  context 'fee exceeds amount' do
    let(:member) { create(:member) }
    let!(:account) { member.get_account(:usd).tap { |x| x.update!(balance: 200.0.to_d) } }
    let(:withdraw) { build(:usd_withdraw, sum: 200, member: member) }
    before { BlockchainCurrency.any_instance.expects(:withdraw_fee).once.returns(200) }
    it 'fails validation' do
      expect(withdraw.save).to eq false
      expect(withdraw.errors[:amount]).to match(["must be greater than 0.0"])
    end
  end

  it 'automatically generates TID if it is blank' do
    expect(create(:btc_withdraw, :with_deposit_liability).tid).not_to be_blank
  end

  it 'doesn\'t generate TID if it is not blank' do
    expect(create(:btc_withdraw, :with_deposit_liability, tid: 'TID1234567890xyz').tid).to eq 'TID1234567890xyz'
  end

  it 'validates uniqueness of TID' do
    record1 = create(:btc_withdraw, :with_deposit_liability)
    record2 = build(:btc_withdraw, tid: record1.tid, member: record1.member)
    record2.save
    expect(record2.errors[:tid]).to match(["has already been taken"])
  end

  it 'uppercases TID' do
    record = create(:btc_withdraw, :with_deposit_liability)
    expect(record.tid).to eq record.tid.upcase
  end

  context 'using beneficiary' do
    context 'fiat' do
      let(:withdraw) do
        create(:usd_withdraw,
               :with_beneficiary,
               :with_deposit_liability,
               sum: 200)
      end

      it 'automatically sets rid from beneficiary' do
        expect(withdraw.rid).to eq withdraw.beneficiary.rid
      end
    end

    context 'crypto' do
      let(:withdraw) do
        create(:btc_withdraw,
               :with_beneficiary,
               :with_deposit_liability,
               sum: 2)
      end

      it 'automatically sets rid from beneficiary' do
        expect(withdraw.rid).to eq withdraw.beneficiary.rid
      end
    end

    context 'non-active beneficiary' do
      let(:currency) { Currency.all.sample }
      let(:beneficiary) { create(:beneficiary, state: :pending, currency: currency) }

      # Create deposit before withdraw for valid accounting cause withdraw
      # build callback doesn't trigger deposit creation.
      let!(:deposit) do
        create(:deposit_usd, member: beneficiary.member, amount: 12)
          .accept!
      end

      let(:withdraw) do
        build(:usd_withdraw,
               :with_deposit_liability,
               beneficiary: beneficiary,
               sum: 10,
               member: beneficiary.member)
      end

      it 'automatically sets rid from beneficiary' do
        expect(withdraw.valid?).to be_falsey
        expect(withdraw.errors[:beneficiary]).to include('not active')
      end
    end
  end

  context 'validate min withdrawal sum' do
    let(:member) { create(:member) }
    let!(:account) { member.get_account(:btc).tap { |x| x.update!(balance: 1.0.to_d) } }
    subject { build(:btc_withdraw, sum: 0.1, member: member) }

    before do
      BlockchainCurrency.find_by(currency_id: 'btc').update(min_withdraw_amount: 0.5.to_d)
    end

    it { expect(subject).not_to be_valid }

    it do
      subject.save
      expect(subject.errors[:sum]).to match(["must be greater than or equal to 0.5"])
    end

  end

  context 'validate note length' do
    let(:member)    { create(:member) }
    let!(:account)   { member.get_account(:btc).tap { |x| x.update!(balance: 1.0.to_d) } }
    let(:address)   { 'bitcoincash:qqkv9wr69ry2p9l53lxp635va4h86wv435995w8p2h' }

    let :record do
      Withdraw.new \
        currency:       Currency.find(:btc),
        blockchain_key: 'btc-testnet',
        type:           'Withdraws::Coin',
        member:         member,
        rid:            address,
        sum:            1.0.to_d,
        note:           note
    end

    context 'valid note' do
      let(:note) { 'TEST' }

      it do
        expect(record.save).to eq true
        expect(record.note).to eq 'TEST'
      end
    end

    context 'invalid note' do
      let(:note) { (0...257).map { (65 + rand(26)).chr }.join }

      it do
        expect(record.save).to eq false
        expect(record.errors.full_messages).to include 'Note is too long (maximum is 256 characters)'
      end
    end
  end

  context 'validates sum precision' do
    let(:currency) { Currency.find(:usd) }
    let(:member)    { create(:member) }

    # Create deposit before withdraw for valid accounting cause withdraw
    # build callback doesn't trigger deposit creation.
    let!(:deposit) do
      create(:deposit_usd, member: member, amount: 12)
        .accept!
    end

    let :record do
      build(:usd_withdraw, :with_deposit_liability, :with_beneficiary, member: member, sum: 0.1234)
    end

    it do
      expect(record.valid?).to be_falsey
      expect(record.errors[:amount]).to include("precision must be less than or equal to #{currency.precision}")
      expect(record.errors[:sum]).to include("precision must be less than or equal to #{currency.precision}")
    end
  end

  context 'verify_limits' do
    let!(:member) { create(:member, group: 'vip-1', level: 1) }
    let!(:withdraw_limit) { create(:withdraw_limit, group: 'vip-1', kyc_level: 1, limit_24_hour: 6, limit_1_month: 10) }
    let(:withdraw) { build(:btc_withdraw, :with_deposit_liability, member: member, sum: 0.5.to_d) }

    before do
      Currency.any_instance.unstub(:price)
      Currency.find('btc').update!(price: 10)
      member.get_account(:btc).update!(balance: 1000)
    end

    context 'enough limits' do
      it { expect(withdraw.verify_limits).to be_truthy }
    end

    context 'Withdraw 24 hours limit exceeded' do
      it do
        withdraw.sum = 100
        expect(withdraw.verify_limits).to be_falsey
      end

      it 'withdraw in different currency' do
        Currency.find('usd').update!(price: 1)
        withdraw.sum = 100
        expect(withdraw.verify_limits).to be_falsey
      end
    end

    context 'Withdraw 1 month limit exceeded' do
      before { withdraw.save }
      it do
        withdraw.update(created_at: 2.day.ago)
        withdraw = build(:btc_withdraw, :with_deposit_liability, member: member, sum: 0.6.to_d)
        expect(withdraw.verify_limits).to be_falsey
      end
    end

    context 'zero limits' do
      before { WithdrawLimit.last.update!(limit_24_hour: 0, limit_1_month: 0) }

      it { expect(withdraw.valid?).to be_truthy }
    end

    context 'there are no WLs in DB' do
      before { WithdrawLimit.delete_all }

      it { expect(withdraw.valid?).to be_truthy }
    end
  end
end
