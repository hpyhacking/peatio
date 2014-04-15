require 'spec_helper'

AMQP_CONFIG[:exchange][:test] = {
  name: 'peatio.exchange.test',
  type: 'fanout'
}

AMQP_CONFIG[:queue][:test] = 'peatio.queue.test'

describe AMQPQueue do
  let(:default_exchange) { stub('default_exchange') }
  let(:channel) { stub('channel', default_exchange: default_exchange) }

  before do
    AMQPQueue.unstub(:publish)
    AMQPQueue.stubs(:exchanges).returns({default: default_exchange})
    AMQPQueue.stubs(:channel).returns(channel)
  end

  it "should instantiate exchange use exchange config" do
    channel.expects(:fanout).with('peatio.exchange.test')
    AMQPQueue.exchange(:test)
  end

  it "should publish message on selected exchange" do
    exchange = mock('test exchange')
    channel.expects(:fanout).with('peatio.exchange.test').returns(exchange)
    exchange.expects(:publish).with(JSON.dump(data: 'hello'), {})
    AMQPQueue.publish(:test, data: 'hello')
  end

  it "should publish message on default exchange" do
    default_exchange.expects(:publish).with(JSON.dump(data: 'hello'), routing_key: 'peatio.queue.test')
    AMQPQueue.enqueue(:test, data: 'hello')
  end

end
