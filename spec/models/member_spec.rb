# encoding: UTF-8
# frozen_string_literal: true

describe Member do
  let(:member) { build(:member, :level_3) }
  subject { member }

  describe 'sn' do
    subject(:member) { create(:member, :level_3) }
    it { expect(member.sn).to_not be_nil }
    it { expect(member.sn).to_not be_empty }
    it { expect(member.sn).to match /\ASN[A-Z0-9]{10}$/ }
  end

  describe 'before_create' do
    it 'should unify email' do
      create(:member, email: 'foo@example.com')
      expect(build(:member, email: 'Foo@example.com')).to_not be_valid
    end

    it 'creates accounts for the member' do
      expect do
        member.save!
      end.to change(member.accounts, :count).by(Currency.codes.size)

      Currency.codes.each do |code|
        expect(Account.with_currency(code).where(member_id: member.id).count).to eq 1
      end
    end
  end

  describe '#trades' do
    subject { create(:member, :level_3) }

    it 'should find all trades belong to user' do
      ask = create(:order_ask, member: member)
      bid = create(:order_bid, member: member)
      t1 = create(:trade, ask: ask)
      t2 = create(:trade, bid: bid)
      expect(member.trades.order('id')).to eq [t1, t2]
    end
  end

  describe '.current' do
    let(:member) { create(:member, :level_3) }
    before do
      Thread.current[:user] = member
    end

    after do
      Thread.current[:user] = nil
    end

    specify { expect(Member.current).to eq member }
  end

  describe '.current=' do
    let(:member) { create(:member, :level_3) }
    before { Member.current = member }
    after { Member.current = nil }
    specify { expect(Thread.current[:user]).to eq member }
  end

  describe '#remove_auth' do
    let!(:member) { create(:member, :level_3) }
    let!(:authentication) { create(:authentication, provider: 'OAuth2', member_id: member.id, uid: member.id)}

    it 'should delete authentication' do
      expect do
        member.remove_auth('OAuth2')
      end.to change(Authentication, :count).by(-1)
      expect(member.auth('OAuth2')).to be_nil
    end
  end
end
