require 'spec_helper'

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
    it "should unify email" do
      create(:identity, email: 'foo@example.com')
      build(:identity, email: 'Foo@example.com').should_not be_valid
    end

    it 'creates accounts for the member' do
      expect {
        member.save!
      }.to change(member.accounts, :count).by(Currency.codes.size)

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

  describe 'send activation after create' do
    let(:auth_hash) {
      {
        'provider' => 'identity',
        'info' => { 'email' => 'foobar@peatio.dev' }
      }
    }

    it 'create activation' do
      expect {
        Member.from_auth(auth_hash)
      }.to change(Token::Activation, :count).by(1)
    end
  end

  describe '#send_password_changed_notification' do
    let(:member) { create :member }

    before do
      member.send_password_changed_notification
      @mail = ActionMailer::Base.deliveries.last
    end

    it { expect(ActionMailer::Base.deliveries).not_to be_empty }
    it { expect(@mail.subject).to match "Your password changed" }
  end

  describe '#trades' do
    subject { create(:member) }

    it "should find all trades belong to user" do
      ask = create(:order_ask, member: member)
      bid = create(:order_bid, member: member)
      t1 = create(:trade, ask: ask)
      t2 = create(:trade, bid: bid)
      member.trades.order('id').should == [t1, t2]
    end
  end

  describe ".current" do
    let(:member) { create(:member) }
    before do
      Thread.current[:user] = member
    end

    after do
      Thread.current[:user] = nil
    end

    specify { Member.current.should == member }
  end

  describe ".current=" do
    let(:member) { create(:member) }
    before { Member.current = member }
    after { Member.current = nil }
    specify { Thread.current[:user].should == member }
  end

  describe "#unread_messages" do
    let!(:user) { create(:member) }

    let!(:ticket) { create(:ticket, author: user) }
    let!(:comment) { create(:comment, ticket: ticket) }

    before { ReadMark.delete_all }

    specify { user.unread_comments.count.should == 1 }

  end

  describe "#identity" do
    it "should not raise but return nil when authentication is not found" do
      member = create(:member)
      expect(member.identity).to be_nil
    end
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

    describe 'search by phone number' do
      let(:member) { create(:member) }
      subject { Member.search(field: 'phone_number', term: member.phone_number) }

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

  describe "#create_auth_for_identity" do
    let(:identity) { create(:identity) }
    let(:member) { create(:member, email: identity.email) }

    it "should create the authentication" do
      expect do
        member.create_auth_for_identity(identity)
      end.to change(Identity, :count).by(1)
    end
  end

  describe "#remove_auth" do
    let!(:identity) { create(:identity) }
    let!(:member) { create(:member, email: identity.email) }
    let!(:weibo_auth) { create(:authentication, provider: 'weibo', member_id: member.id)}
    let!(:identity_auth) { create(:authentication, provider: 'identity', member_id: member.id, uid: identity.id)}

    context "third party" do
      it "should delete the weibo auth" do
        expect do
          expect do
            member.remove_auth('weibo')
          end.not_to change(Identity, :count)
        end.to change(Authentication, :count).by(-1)
        member.auth('weibo').should be_nil
      end
    end

    context "identity" do
      it "should delete the ideneity auth and the identity" do
        expect do
          expect do
            member.remove_auth('identity')
          end.to change(Identity, :count).by(-1)
        end.to change(Authentication, :count).by(-1)
        member.auth('identity').should be_nil
      end
    end
  end

  describe "#locate_email" do
    context "Email is blank" do
      let!(:member) { create(:member, email: nil) }
      let(:auth) {
        {'info' => { 'email' => nil}}
      }

      it "should return nil" do
        Member.count.should == 1
        Member.send(:locate_email, auth).should be_nil
      end
    end

    context "Emails is exist and can find member" do
      let(:email) { 'fuck@chinese.gov' }
      let!(:member) { create(:member, email: email) }
      let(:auth) {
        { 'provider' => 'weibo', 'uid' => 'hehe', 'info' => { 'email' => email} }
      }

      it "should return the user and create the auth" do
        expect do
          Member.send(:locate_email, auth).should == member
        end.to change(Authentication, :count).by(1)
      end
    end

    context "Email is exist but can not find member" do
      let(:email) { 'fuck@chinese.gov' }
      let!(:member) { create(:member, email: email) }

      let(:auth) {
        { 'provider' => 'weibo', 'uid' => 'hehe', 'info' => { 'email' => email + 'veryhard'} }
      }

      it "should not create auth and return nil" do
        expect do
          Member.send(:locate_email, auth).should be_nil
        end.not_to change(Authentication, :count)
      end
    end
  end


end
