# encoding: UTF-8
# frozen_string_literal: true

describe TradingFee, 'Relationships' do
  context 'belongs to market' do
    context 'null market_id' do
      subject { build(:trading_fee) }
      it { expect(subject.valid?).to be_truthy }
    end

    context 'existing market_id' do
      subject { build(:trading_fee, market_id: :btcusd) }
      it { expect(subject.valid?).to be_truthy }
    end

    context 'non-existing market_id' do
      subject { build(:trading_fee, market_id: :usdbtc) }
      it { expect(subject.valid?).to be_falsey }
    end
  end
end

describe TradingFee, 'Validations' do
  before(:each) { TradingFee.delete_all }

  context 'market_type presence' do
    context 'nil market_type' do
      subject { build(:trading_fee, market_id: :btceth, market_type: '') }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'market_type inclusion' do
    context 'nil market_type' do
      subject { build(:trading_fee, market_id: :btceth, market_type: 'invalid') }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'group presence' do
    context 'nil group' do
      subject { build(:trading_fee, market_id: :btceth, group: nil) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'empty string group' do
      subject { build(:trading_fee, market_id: :btceth, group: '') }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'group uniqueness' do
    context 'different markets' do
      before { create(:trading_fee, market_id: :btcusd, group: 'vip-1') }

      context 'same group' do
        subject { build(:trading_fee, market_id: :btceth, group: 'vip-1') }
        it { expect(subject.valid?).to be_truthy }
      end

      context 'different group' do
        subject { build(:trading_fee, market_id: :btceth, group: 'vip-2') }
        it { expect(subject.valid?).to be_truthy }
      end

      context ':any group' do
        before { create(:trading_fee, market_id: :btcusd, group: :any) }
        subject { build(:trading_fee, market_id: :btceth, group: :any) }
        it { expect(subject.valid?).to be_truthy }
      end
    end

    context 'same market' do
      before { create(:trading_fee, market_id: :btcusd, group: 'vip-1') }

      context 'same group' do
        subject { build(:trading_fee, market_id: :btcusd, group: 'vip-1') }
        it { expect(subject.valid?).to be_falsey }
      end

      context 'different group' do
        subject { build(:trading_fee, market_id: :btcusd, group: 'vip-2') }
        it { expect(subject.valid?).to be_truthy }
      end

      context ':any group' do
        before { create(:trading_fee, market_id: :btcusd, group: :any) }
        subject { build(:trading_fee, market_id: :btcusd, group: :any) }
        it { expect(subject.valid?).to be_falsey }
      end
    end

    context ':any market' do
      before { create(:trading_fee, group: 'vip-1') }

      context 'same group' do
        subject { build(:trading_fee, group: 'vip-1') }
        it { expect(subject.valid?).to be_falsey }
      end

      context 'different group' do
        subject { build(:trading_fee, group: 'vip-2') }
        it { expect(subject.valid?).to be_truthy }
      end

      context ':any group' do
        before { create(:trading_fee, group: :any) }
        subject { build(:trading_fee, group: :any) }
        it { expect(subject.valid?).to be_falsey }
      end
    end
  end

  context 'maker, taker numericality' do
    context 'non decimal maker/taker' do
      subject { build(:trading_fee, maker: '1', taker: '1') }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'valid trading_fee' do
      subject { build(:trading_fee, maker: 0.1, taker: 0.2) }
      it { expect(subject.valid?).to be_truthy }
    end
  end

  context 'market_id presence' do
    context 'nil group' do
      subject { build(:trading_fee, market_id: nil) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'empty string group' do
      subject { build(:trading_fee, market_id: '') }
      it { expect(subject.valid?).to be_falsey }
    end
  end

  context 'market_id inclusion in' do
    context 'invalid market_id' do
      subject { build(:trading_fee, market_id: :ethusd) }
      it { expect(subject.valid?).to be_falsey }
    end

    context 'valid trading_fee' do
      subject { build(:trading_fee, market_id: :btcusd) }
      it { expect(subject.valid?).to be_truthy }
    end
  end
end

describe TradingFee, 'Class Methods' do
  before(:each) { TradingFee.delete_all }

  context '#for' do
    let!(:member) { create(:member) }

    context 'get trading_fee with marker_id and group' do
      before do
        create(:trading_fee, market_id: :btcusd, group: 'vip-0')
        create(:trading_fee, market_id: :any, group: 'vip-0')
        create(:trading_fee, market_id: :btcusd, group: :any)
        create(:trading_fee, market_id: :any, group: :any)
      end

      let(:order) { Order.new(member: member, market_id: :btcusd) }
      subject { TradingFee.for(group: order.member.group, market_id: order.market_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.market_id).to eq('btcusd')
        expect(subject.group).to eq('vip-0')
      end
    end

    context 'get trading_fee with group' do
      before do
        create(:trading_fee, market_id: :any, group: 'vip-1')
        create(:trading_fee, market_id: :btcusd, group: :any)
        create(:trading_fee, market_id: :any, group: :any)
      end

      let(:order) { Order.new(member: member, market_id: :btcusd) }
      subject { TradingFee.for(group: order.member.group, market_id: order.market_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.market_id).to eq('btcusd')
        expect(subject.group).to eq('any')
      end
    end

    context 'get trading_fee with market_id' do
      before do
        create(:trading_fee, market_id: :any, group: 'vip-0')
        create(:trading_fee, market_id: :btcusd, group: :any)
        create(:trading_fee, market_id: :any, group: :any)
      end

      let(:order) { Order.new(member: member, market_id: :btceth) }
      subject { TradingFee.for(group: order.member.group, market_id: order.market_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.market_id).to eq('any')
        expect(subject.group).to eq('vip-0')
      end
    end

    context 'get default trading_fee' do
      before do
        create(:trading_fee, market_id: :any, group: 'vip-1')
        create(:trading_fee, market_id: :btcusd, group: :any)
        create(:trading_fee, market_id: :any, group: :any)
      end

      let(:order) { Order.new(member: member, market_id: :btceth) }
      subject { TradingFee.for(group: order.member.group, market_id: order.market_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.market_id).to eq('any')
        expect(subject.group).to eq('any')
      end
    end

    context 'get default trading_fee (doesnt create it)' do
      let(:order) { Order.new(member: member, market_id: :btceth) }
      subject { TradingFee.for(group: order.member.group, market_id: order.market_id) }

      it do
        expect(subject).to be_truthy
        expect(subject.market_id).to eq('any')
        expect(subject.group).to eq('any')
      end
    end
  end
end
