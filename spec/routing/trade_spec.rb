describe 'routes for trade', type: :routing do
  it 'routes /markets/xxxyyy to the trade controller' do
    Market.expects(:find_by_id).with('xxxyyy').returns(Market.new(id: 'xxxyyy', base_unit: 'xxx', quote_unit: 'yyy'))
    expect(get: '/markets/xxxyyy').to be_routable

    Market.expects(:find_by_id).with('yyyxxx').returns(nil)
    expect(get: '/markets/yyyxxx').to_not be_routable
  end
end
