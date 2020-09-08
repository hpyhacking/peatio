# encoding: UTF-8
# frozen_string_literal: true

describe WithdrawLimit, 'Validations' do
  before(:each) { WithdrawLimit.delete_all }

  context 'group presence' do
    context 'nil group' do
      subject { build(:withdraw_limit, group: nil) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'empty string group' do
      subject { build(:withdraw_limit, group: '') }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'group uniqueness' do
    context 'same kyc_level' do
      before { create(:withdraw_limit, kyc_level: 1, group: 'vip-1') }

      context 'same group' do
        subject { build(:withdraw_limit, kyc_level: 1, group: 'vip-1') }
        it { expect(subject.valid?).to be_falsey }
      end

      context 'different group' do
        subject { build(:withdraw_limit, kyc_level: 1, group: 'vip-2') }
        it { expect(subject.valid?).to be_truthy }
      end

      context ':any group' do
        before { create(:withdraw_limit, kyc_level: 1, group: :any) }
        subject { build(:withdraw_limit, kyc_level: 1, group: :any) }
        it { expect(subject.valid?).to be_falsey }
      end
    end
  end

  context 'limit_24_hour, limit_1_month numericality' do
    context 'non decimal limit_24_hour/limit_1_month' do
      subject { build(:withdraw_limit, limit_24_hour: '1', limit_1_month: '1') }
      it do
        expect(subject.valid?).to be_truthy
      end
    end

    context 'valid withdraw_limit' do
      subject { build(:withdraw_limit, limit_24_hour: 0.1, limit_1_month: 0.2) }
      it { expect(subject.valid?).to be_truthy }
    end
  end
end

describe WithdrawLimit, 'Class Methods' do
  before(:each) { WithdrawLimit.delete_all }

  context '#for' do
    let!(:member) { create(:member) }


    context 'get withdraw_limit with kyc_level and group' do
      let!(:member) { create(:member, level: 1) }
      before do
        create(:withdraw_limit, kyc_level: 1, group: 'vip-0')
        create(:withdraw_limit, group: 'vip-0')
        create(:withdraw_limit, kyc_level: 2, group: :any)
        create(:withdraw_limit, kyc_level: 3, group: :any)
      end

      let(:withdraw) { Withdraw.new(member: member) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group) }

      it do
        expect(subject).to be_truthy
        expect(subject.group).to eq('vip-0')
        expect(subject.kyc_level).to eq('1')
      end
    end

    context 'get withdraw_limit with group' do
      before do
        create(:withdraw_limit, group: 'vip-0')
        create(:withdraw_limit, group: 'vip-1')
        create(:withdraw_limit, group: :any)
      end

      let(:withdraw) { Withdraw.new(member: member) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group) }

      it do
        expect(subject).to be_truthy
        expect(subject.group).to eq('vip-0')
      end
    end

    context 'get withdraw_limit with kyc_level' do
      before do
        create(:withdraw_limit, kyc_level: 1)
      end

      let(:withdraw) { Withdraw.new(member: member) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group) }

      it do
        expect(subject).to be_truthy
        expect(subject.group).to eq('any')
      end
    end

    context 'get default withdraw_limit' do
      before do
        create(:withdraw_limit, group: 'vip-1')
        create(:withdraw_limit, group: :any)
      end

      let(:withdraw) { Withdraw.new(member: member) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group) }

      it do
        expect(subject).to be_truthy
        expect(subject.group).to eq('any')
      end
    end

    context 'get default withdraw_limit (doesnt create it)' do
      let(:withdraw) { Withdraw.new(member: member) }
      subject { WithdrawLimit.for(kyc_level: withdraw.member.level, group: withdraw.member.group) }

      it do
        expect(subject).to be_truthy
        expect(subject.group).to eq('any')
      end
    end
  end
end
