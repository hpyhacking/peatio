describe OrderBid do
  subject { create(:order_bid) }

  it { expect(subject.compute_locked).to eq subject.volume * subject.price }

  context 'compute locked for market order' do
    let(:price_levels) do
      [
        ['100'.to_d, '10.0'.to_d],
        ['101'.to_d, '10.0'.to_d],
        ['102'.to_d, '10.0'.to_d],
        ['200'.to_d, '10.0'.to_d]
      ]
    end

    before do
      global = Global.new('btcusd')
      global.stubs(:asks).returns(price_levels)
      Global.stubs(:[]).returns(global)
    end

    it 'should require a little' do
      expect(OrderBid.new(volume: '5'.to_d, ord_type: 'market').compute_locked).to eq '500'.to_d * OrderBid::LOCKING_BUFFER_FACTOR
    end

    it 'should require more' do
      expect(OrderBid.new(volume: '25'.to_d, ord_type: 'market').compute_locked).to eq '2520'.to_d * OrderBid::LOCKING_BUFFER_FACTOR
    end

    it 'should raise error if the market is not deep enough' do
      expect do
        OrderBid.new(volume: '50'.to_d, ord_type: 'market').compute_locked
      end.to raise_error(RuntimeError, 'Market is not deep enough')
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
