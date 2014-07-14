# == Schema Information
#
# Table name: members
#
#  id                    :integer          not null, primary key
#  sn                    :string(255)
#  name                  :string(255)
#  display_name          :string(255)
#  email                 :string(255)
#  identity_id           :integer
#  created_at            :datetime
#  updated_at            :datetime
#  state                 :integer
#  activated             :boolean
#  country_code          :integer
#  phone_number          :string(255)
#  phone_number_verified :boolean
#

require 'spec_helper'

describe Member do
  subject(:member) { build(:member) }

  describe 'sn' do
    subject(:member) { create(:member) }
    it { expect(member.sn).to_not be_nil }
    it { expect(member.sn).to_not be_empty }
    it { expect(member.sn).to match /^PEA.*TIO$/ }
  end

  describe 'before_create' do
    it 'creates accounts for the member' do
      expect {
        member.save!
      }.to change(member.accounts, :count).by(Currency.codes.size)

      Currency.codes.each do |code|
        expect(Account.with_currency(code).where(member_id: member.id).count).to eq 1
      end
    end
  end

  describe 'send activation after create' do
    let(:auth_auth) {
      {
        'info' => { 'email' => 'foobar@peatio.dev' }
      }
    }

    it 'create activation' do
      expect {
        Member.from_auth(auth_auth)
      }.to change(Activation, :count).by(1)
    end
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
    let!(:member) { create(:member) }
    let!(:ticket) { create(:ticket, author: member) }
    let!(:comment) { create(:comment, ticket: ticket) }
    before { ticket.mark_as_read! for: member }

    specify { member.unread_comments.should == [comment] }
  end

end
