require 'spec_helper'

describe Worker::DepositCoin do

  subject { Worker::DepositCoin.new }

  context "sendmany transaction" do
    let(:raw) do
      {:amount=>0.2,
       :confirmations=>39,
       :blockhash=>
        "0000000000d744827317b3f679c52d0090243a13153c6082e0e65cb83fa1193d",
       :blockindex=>1,
       :blocktime=>1412317163,
       :txid=>"1a33b61174e5c52c189af4169b6919d059a0024ee6526326961fe6dd8af2e260",
       :walletconflicts=>[],
       :time=>1412317158,
       :timereceived=>1412317158,
       :details=>
        [{"account"=>"payment",
          "address"=>"mov9LqpntN18cuyzUDBoaS8vPY8pF421Y3",
          "category"=>"receive",
          "amount"=>0.1},
         {"account"=>"payment",
          "address"=>"mqRtfJSdgrbbgMPasq4j3br1G4h3AoJ4hE",
          "category"=>"receive",
          "amount"=>0.1}],
       :hex=> ''}
    end

    let(:payload) do
      {'txid' => '1a33b61174e5c52c189af4169b6919d059a0024ee6526326961fe6dd8af2e260',
       'channel_key' => 'satoshi'}
    end

    before do
      create(:btc_payment_address, address: 'mov9LqpntN18cuyzUDBoaS8vPY8pF421Y3')
      create(:btc_payment_address, address: 'mqRtfJSdgrbbgMPasq4j3br1G4h3AoJ4hE')
      subject.stubs(:get_raw).returns(raw)
    end

    it "should deposit many accounts" do
      lambda {
        subject.process payload, {}, {}
      }.should change(Deposit, :count).by(2)
    end
  end

end
