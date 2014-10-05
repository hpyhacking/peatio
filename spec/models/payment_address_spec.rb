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

  context '#construct_memo' do
    subject { PaymentAddress.new }

    it "constructs memo" do
      subject.construct_memo(Account.new(member_id: 60, id: 100)).should == '601002'
      subject.construct_memo(Account.new(member_id: 12345678901, id: 12345678902)).should == '1234567890112345678902B'
    end
  end

  context '#destruct_memo' do
    let(:account) { create(:member).get_account('btc') }
    let!(:memo)   { subject.construct_memo account }

    subject { PaymentAddress.new }

    it "returns the corresponding account if memo is valid" do
      subject.destruct_memo(memo).should == account
    end

    it "returns nil if size bit is missing" do
      wrong_memo = memo[0..-2]
      subject.destruct_memo(wrong_memo).should be_nil
    end
  end

end
