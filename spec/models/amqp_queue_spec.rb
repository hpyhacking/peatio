# encoding: UTF-8
# frozen_string_literal: true

describe AMQP::Queue do
  let(:config) do
    Hashie::Mash.new(connect:   { host: '127.0.0.1' },
                     exchange:  { testx: { name: 'testx', type: 'fanout' } },
                     queue:     { testq: { name: 'testq', durable: true },
                                  testd: { name: 'testd' } },
                     binding:   {
                       test:    { queue: 'testq', exchange: 'testx' },
                       testd:   { queue: 'testd' },
                       default: { queue: 'testq' }
                     })
  end

  let(:default_exchange) { stub('default_exchange') }
  let(:channel) { stub('channel', default_exchange: default_exchange) }

  before do
    AMQP::Config.stubs(:data).returns(config)

    AMQP::Queue.unstub(:publish)
    AMQP::Queue.stubs(:exchanges).returns(default: default_exchange)
    AMQP::Queue.stubs(:channel).returns(channel)
  end

  it 'should instantiate exchange use exchange config' do
    channel.expects(:fanout).with('testx')
    AMQP::Queue.exchange(:testx)
  end

  it 'should publish message on selected exchange' do
    exchange = mock('test exchange')
    channel.expects(:fanout).with('testx').returns(exchange)
    exchange.expects(:publish).with(JSON.dump(data: 'hello'), {})
    AMQP::Queue.publish(:testx, data: 'hello')
  end

  it 'should publish message on default exchange' do
    default_exchange.expects(:publish).with(JSON.dump(data: 'hello'), routing_key: 'testd')
    AMQP::Queue.enqueue(:testd, data: 'hello')
  end
end
