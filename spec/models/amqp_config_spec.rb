# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class Test
  end
end

describe AMQPConfig do
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
    AMQPConfig.stubs(:data).returns(config)
  end

  it 'should tell client how to connect' do
    expect(AMQPConfig.connect).to eq ({ 'host' => '127.0.0.1' })
  end

  it 'should return queue settings' do
    expect(AMQPConfig.queue(:testq)).to eq ['testq', { durable: true }]
  end

  it 'should return exchange settings' do
    expect(AMQPConfig.exchange(:testx)).to eq %w[fanout testx]
  end

  it 'should return binding queue' do
    expect(AMQPConfig.binding_queue(:test)).to eq ['testq', { durable: true }]
  end

  it 'should return binding exchange' do
    expect(AMQPConfig.binding_exchange(:test)).to eq %w[fanout testx]
  end

  it 'should set exchange to nil when binding use default exchange' do
    expect(AMQPConfig.binding_exchange(:default)).to be_nil
  end

  it 'should find binding worker' do
    expect(AMQPConfig.binding_worker(:test)).to be_instance_of(Worker::Test)
  end

  it 'should return queue name of binding' do
    expect(AMQPConfig.routing_key(:testd)).to eq 'testq'
  end

  it 'should return topics to subscribe' do
    expect(AMQPConfig.topics(:topic)).to eq ['test.a', 'test.b']
  end
end
