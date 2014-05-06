require 'spec_helper'

module Worker
  class Test
  end
end

describe AMQPConfig do

  let(:config) do
    Hashie::Mash.new({
      connect:   { host: '127.0.0.1' },
      exchange:  { testx:  { name: 'testx', type: 'fanout' },
                   testd:  { name: 'testd', type: 'direct' },
                   topicx: { name: 'topicx', type: 'topic' } },
      queue:     { testq: { name: 'testq', durable: true } },
      binding:   {
        test:    { queue: 'testq', exchange: 'testx' },
        testd:   { queue: 'testq', exchange: 'testd' },
        topic:   { queue: 'testq', exchange: 'topicx', topics: 'test.a,test.b' },
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
    AMQPConfig.queue(:testq).should == ['testq', {durable: true}]
  end

  it "should return exchange settings" do
    AMQPConfig.exchange(:testx).should == ['fanout', 'testx']
  end

  it "should return binding queue" do
    AMQPConfig.binding_queue(:test).should == ['testq', {durable: true}]
  end

  it "should return binding exchange" do
    AMQPConfig.binding_exchange(:test).should == ['fanout', 'testx']
  end

  it "should set exchange to nil when binding use default exchange" do
    AMQPConfig.binding_exchange(:default).should be_nil
  end

  it "should find binding worker" do
    AMQPConfig.binding_worker(:test).should be_instance_of(Worker::Test)
  end

  it "should return queue name of binding" do
    AMQPConfig.routing_key(:testd).should == 'testq'
  end

  it "should return topics to subscribe" do
    AMQPConfig.topics(:topic).should == ['test.a', 'test.b']
  end

end
