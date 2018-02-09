describe Member do
  let(:member) { build(:member) }
  subject { member }

  describe 'sn' do
    subject(:member) { create(:member) }
    it { expect(member.sn).to_not be_nil }
    it { expect(member.sn).to_not be_empty }
    it { expect(member.sn).to match /^PEA.*TIO$/ }
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

  describe 'build id_document before create' do
    it 'create id_document for the member' do
      member.save
      expect(member.reload.id_document).to_not be_blank
    end
  end

  describe '#trades' do
    subject { create(:member) }

    it 'should find all trades belong to user' do
      ask = create(:order_ask, member: member)
      bid = create(:order_bid, member: member)
      t1 = create(:trade, ask: ask)
      t2 = create(:trade, bid: bid)
      expect(member.trades.order('id')).to eq [t1, t2]
    end
  end

  describe '.current' do
    let(:member) { create(:member) }
    before do
      Thread.current[:user] = member
    end

    after do
      Thread.current[:user] = nil
    end

    specify { expect(Member.current).to eq member }
  end

  describe '.current=' do
    let(:member) { create(:member) }
    before { Member.current = member }
    after { Member.current = nil }
    specify { expect(Thread.current[:user]).to eq member }
  end

  describe 'Member.search' do
    before do
      create(:member)
      create(:member)
      create(:member)
    end

    describe 'search without any condition' do
      subject { Member.search(field: nil, term: nil) }

      it { expect(subject.count).to eq(3) }
    end

    describe 'search by email' do
      let(:member) { create(:member) }
      subject { Member.search(field: 'email', term: member.email) }

      it { expect(subject.count).to eq(1) }
      it { expect(subject).to be_include(member) }
    end

    describe 'search by name' do
      let(:member) { create(:verified_member) }
      subject { Member.search(field: 'name', term: member.name) }

      it { expect(subject.count).to eq(1) }
      it { expect(subject).to be_include(member) }
    end

    describe 'search by wallet address' do
      let(:fund_source) { create(:btc_fund_source) }
      let(:member) { fund_source.member }
      subject { Member.search(field: 'wallet_address', term: fund_source.uid) }

      it { expect(subject.count).to eq(1) }
      it { expect(subject).to be_include(member) }
    end

    describe 'search by deposit address' do
      let(:payment_address) { create(:btc_payment_address) }
      let(:member) { payment_address.account.member }
      subject { Member.search(field: 'wallet_address', term: payment_address.address) }

      it { expect(subject.count).to eq(1) }
      it { expect(subject).to be_include(member) }
    end
  end

  describe '#remove_auth' do
    let!(:member) { create(:member) }
    let!(:authentication) { create(:authentication, provider: 'OAuth2', member_id: member.id, uid: member.id)}

    it 'should delete authentication' do
      expect do
        member.remove_auth('OAuth2')
      end.to change(Authentication, :count).by(-1)
      expect(member.auth('OAuth2')).to be_nil
    end
  end
end
