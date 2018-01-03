describe OrderAsk do
  subject { create(:order_ask) }

  it { expect(subject.compute_locked).to eq subject.volume }

  context 'compute locked for market order' do
    let(:price_levels) do
      [
        ['202'.to_d, '10.0'.to_d],
        ['201'.to_d, '10.0'.to_d],
        ['200'.to_d, '10.0'.to_d],
        ['100'.to_d, '10.0'.to_d]
      ]
    end

    before do
      global = Global.new('btcusd')
      global.stubs(:asks).returns(price_levels)
      Global.stubs(:[]).returns(global)
    end

    it 'should require a little' do
      bid = OrderBid.new(volume: '5'.to_d, ord_type: 'market').compute_locked
      expect(bid).to eq('1010'.to_d * OrderBid::LOCKING_BUFFER_FACTOR)
    end

    it 'should raise error if volume is too large' do
      expect do
        OrderBid.new(volume: '30'.to_d, ord_type: 'market').compute_locked
      end.not_to raise_error

      expect do
        OrderBid.new(volume: '31'.to_d, ord_type: 'market').compute_locked
      end.to raise_error(RuntimeError, 'Market is not deep enough')
    end
  end
end
