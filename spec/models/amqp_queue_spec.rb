require 'spec_helper'

describe AMQPQueue do
  let(:config) do
    Hashie::Mash.new({
      connect:   { host: '127.0.0.1' },
      exchange:  { testx: { name: 'testx', type: 'fanout' } },
      queue:     { testq: { name: 'testq', durable: true },
                   testd: { name: 'testd'} },
      binding:   {
        test:    { queue: 'testq', exchange: 'testx' },
        testd:   { queue: 'testd' },
        default: { queue: 'testq' }
      }
    })
  end

  let(:default_exchange) { stub('default_exchange') }
  let(:channel) { stub('channel', default_exchange: default_exchange) }

  before do
    AMQPConfig.stubs(:data).returns(config)

    AMQPQueue.unstub(:publish)
    AMQPQueue.stubs(:exchanges).returns({default: default_exchange})
    AMQPQueue.stubs(:channel).returns(channel)
  end

  it "should instantiate exchange use exchange config" do
    channel.expects(:fanout).with('testx')
    AMQPQueue.exchange(:testx)
  end

  it "should publish message on selected exchange" do
    exchange = mock('test exchange')
    channel.expects(:fanout).with('testx').returns(exchange)
    exchange.expects(:publish).with(JSON.dump(data: 'hello'), {})
    AMQPQueue.publish(:testx, data: 'hello')
  end

  it "should publish message on default exchange" do
    default_exchange.expects(:publish).with(JSON.dump(data: 'hello', locale: I18n.locale), routing_key: 'testd')
    AMQPQueue.enqueue(:testd, data: 'hello')
  end

end

describe AMQPQueue::Worker do
  describe 'switch I18n.locale' do
    let(:worker) { Class.new{ include AMQPQueue::Worker }.new }
    subject { worker }

    it { should be_respond_to(:process) }

    it "switch I18n.locale to zh-CN" do
      worker.process({locale: 'zh-CN'})
      expect(I18n.locale).to eq(:'zh-CN')
    end

    after do
      I18n.locale = I18n.default_locale
    end
  end
end
