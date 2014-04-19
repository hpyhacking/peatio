require 'spec_helper'

describe AMQPConfig do

  let(:config) do
    Hashie::Mash.new({
      connect:   { host: '127.0.0.1' },
      exchange:  { testx: { name: 'testx', type: 'fanout' } },
      queue:     { testq: { name: 'testq', durable: true } },
      binding:   {
        test:    { queue: 'testq', exchange: 'testx' },
        default: { queue: 'testq' }
      }
    })
  end

  before do
    AMQPConfig.stubs(:data).returns(config)
  end

  it "should tell client how to connect" do
    AMQPConfig.connect.should == {'host' => '127.0.0.1'}
  end

  it "should return queue settings" do
    AMQPConfig.queue(:testq).should == ['testq', {}]
  end

  it "should return exchange settings" do
    AMQPConfig.exchange(:testx).should == ['fanout', 'testx']
  end

  it "should return binding queue" do
    AMQPConfig.binding_queue(:test).should == ['testq', {}]
  end

  it "should return binding exchange" do
    AMQPConfig.binding_exchange(:test).should == ['fanout', 'testx']
  end

  it "should set exchange to nil when binding use default exchange" do
    AMQPConfig.binding_exchange(:default).should be_nil
  end
end
