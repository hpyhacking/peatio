# encoding: UTF-8
# frozen_string_literal: true

describe Workers::Daemons::Upstream do
  subject { Workers::Daemons::Upstream.new }

  context '#run' do
    context 'with empty data in markets' do
      it 'returns []' do
        expect(subject.run).to eq([])
      end
    end

    # context 'market data with opendax upstream' do
    #   before do
    #     Market.find('btcusd').update!(data: {upstream: {"driver": "opendax", "target": 'btcusd', "rest": "http://localhost", "websocket": "wss://localhost"}})
    #   end
    #   it 'starts upstream' do
    #     subject.run
    #   end
    # end
  end
end
