require 'spec_helper'

shared_context "submit order", :a => :b do
  let(:ask_member) { create(:member) }
  let(:bid_member) { create(:member) }
  let(:order_bid) { create(:order_bid, price: bid[0], volume: bid[1], member: bid_member) }
  let(:order_ask) { create(:order_ask, price: ask[0], volume: ask[1], member: ask_member) }

  before do
    OrderAsk.stubs(:head).returns(order_ask)
    OrderBid.stubs(:head).returns(order_bid)
    order_bid.stubs(:strike)
    order_ask.stubs(:strike)
  end

  subject { Matching.new(:cnybtc).run(latest_price) }
end

describe Matching do
  include_context "submit order"

  describe "full matching" do
    let(:latest_price) { "1.0".to_d }
    let(:bid) { ["1.0".to_d, "10.0".to_d] }
    let(:ask) { ["1.0".to_d, "10.0".to_d] }
    it { expect(subject.price).to be_d "1.0" }
    it { expect(subject.volume).to be_d "10.0" }
  end

  describe "latest price matching" do
    let(:latest_price) { "1.15".to_d }
    let(:bid) { ["1.2".to_d, "5.0".to_d] }
    let(:ask) { ["1.1".to_d, "10.0".to_d] }
    it { expect(subject.price).to be_d "1.15" }
    it { expect(subject.volume).to be_d "5.0" }
  end

  describe "ask price matching" do
    let(:latest_price) { "1.0".to_d }
    let(:bid) { ["1.2".to_d, "10.0".to_d] }
    let(:ask) { ["1.1".to_d, "15.0".to_d] }
    it { expect(subject.price).to be_d "1.1" }
    it { expect(subject.volume).to be_d "10.0" }
  end

  describe "bid price matching" do
    let(:latest_price) { "1.3".to_d }
    let(:bid) { ["1.2".to_d, "0.1".to_d] }
    let(:ask) { ["1.1".to_d, "10.0".to_d] }
    it { expect(subject.price).to be_d "1.2" }
    it { expect(subject.volume).to be_d "0.1" }
  end

  describe "latest price 1.0" do
    let(:latest_price) { "1.0".to_d }
    let(:bid) { ["1.0".to_d, "10.0".to_d] }
    let(:ask) { ["1.0".to_d, "10.0".to_d] }
    it { expect(subject.ask).to eql order_ask }
    it { expect(subject.bid).to eql order_bid }
    it { expect(order_ask.member.trades).to include subject }
    it { expect(order_bid.member.trades).to include subject }
  end

  describe "persistent trade" do
    let(:latest_price) { "1.0".to_d }
    let(:bid) { ["1.0".to_d, "10.0".to_d] }
    let(:ask) { ["1.0".to_d, "10.0".to_d] }
    it { expect(subject).to be_a(Trade) }
    it { expect(subject.bid_member_sn).to eq(bid_member.sn) }
    it { expect(subject.ask_member_sn).to eq(ask_member.sn) }
  end
end
