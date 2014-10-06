require 'spec_helper'

describe PaymentAddress do

  context ".create" do
    before do
      PaymentAddress.any_instance.stubs(:id).returns(1)
    end

    it "generate address after commit" do
      AMQPQueue.expects(:enqueue)
        .with(:deposit_coin_address,
              {payment_address_id: 1, currency: 'btc'},
              {persistent: true})

      PaymentAddress.create currency: :btc
    end
  end

  context 'memo' do
    let(:created_at) { Time.at(1234567) }
    let(:member)     { create(:member) }
    let(:account)    { member.get_account('btc') }
    let(:memo)       { "#{member.id}567"}

    before { Timecop.freeze(created_at) }
    after  { Timecop.return }

    it "constructs memo" do
      PaymentAddress.construct_memo(account).should == memo
    end

    it "returns the corresponding account if memo is valid" do
      PaymentAddress.destruct_memo(memo).should == member
    end

    it "returns nil if last bit is missing" do
      wrong_memo = memo[0..-2]
      PaymentAddress.destruct_memo(wrong_memo).should be_nil
    end

    it "returns nil if first bit is modified" do
      wrong_memo = "0" + memo[1..-1]
      PaymentAddress.destruct_memo(wrong_memo).should be_nil
    end

    it "returns memo" do
      PaymentAddress.new(address: "chongzhi|#{memo}").memo.should == memo
    end
  end

end
