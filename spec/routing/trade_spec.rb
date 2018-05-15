# encoding: UTF-8
# frozen_string_literal: true

describe 'routes for trade', type: :routing do
  it 'routes /markets/xxxyyy to the trade controller' do
    Market.expects(:find_by_id).with('xxxyyy').returns(Market.new(id: 'xxxyyy', ask_unit: 'xxx', bid_unit: 'yyy'))
    expect(get: '/markets/xxxyyy').to be_routable

    Market.expects(:find_by_id).with('yyyxxx').returns(nil)
    expect(get: '/markets/yyyxxx').to_not be_routable
  end
end
