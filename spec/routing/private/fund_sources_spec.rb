require 'spec_helper'

describe 'fund_sources' do
  it { expect(get('/fund_sources_cny')).to be_routable }
  it { expect(get('/fund_sources_cny')).to route_to \
       controller: 'private/fund_sources',
       action: 'index',
       currency: 'cny'
  }
end
