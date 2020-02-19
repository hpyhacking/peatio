# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class Test
    end
  end
end

describe AMQP::Config do
  let(:config) do
    Hashie::Mash.new(connect:   { host: '127.0.0.1' },
                     exchange:  { testx:  { name: 'testx', type: 'fanout' },
                                  testd:  { name: 'testd', type: 'direct' },
                                  topicx: { name: 'topicx', type: 'topic' } },
                     queue:     { testq: { name: 'testq', durable: true } },
                     binding:   {
                       test:    { queue: 'testq', exchange: 'testx' },
                       testd:   { queue: 'testq', exchange: 'testd' },
                       topic:   { queue: 'testq', exchange: 'topicx', topics: 'test.a,test.b' },
                       default: { queue: 'testq' }
                     })
  end

  before do
    AMQP::Config.stubs(:data).returns(config)
  end

  it 'should tell client how to connect' do
    expect(AMQP::Config.connect).to eq ({ 'host' => '127.0.0.1' })
  end

  it 'should return queue settings' do
    expect(AMQP::Config.queue(:testq)).to eq ['testq', { durable: true }]
  end

  it 'should return exchange settings' do
    expect(AMQP::Config.exchange(:testx)).to eq %w[fanout testx]
  end

  it 'should return binding queue' do
    expect(AMQP::Config.binding_queue(:test)).to eq ['testq', { durable: true }]
  end

  it 'should return binding exchange' do
    expect(AMQP::Config.binding_exchange(:test)).to eq %w[fanout testx]
  end

  it 'should set exchange to nil when binding use default exchange' do
    expect(AMQP::Config.binding_exchange(:default)).to be_nil
  end

  it 'should find binding worker' do
    expect(AMQP::Config.binding_worker(:test)).to be_instance_of(Workers::AMQP::Test)
  end

  it 'should return queue name of binding' do
    expect(AMQP::Config.routing_key(:testd)).to eq 'testq'
  end

  it 'should return topics to subscribe' do
    expect(AMQP::Config.topics(:topic)).to eq ['test.a', 'test.b']
  end
end
