require 'spec_helper'

describe 'fund_sources' do
  context 'deposit' do
    it { expect(get('/btc_fund_sources')).to be_routable }

    it { expect(get('/btc_fund_sources')).to route_to \
         controller: 'private/fund_sources',
         action: 'index',
         currency: 'btc'
    }

    it { expect(get('/btc_fund_sources/new')).to route_to \
         controller: 'private/fund_sources',
         action: 'new',
         currency: 'btc'
    }

    it { expect(post('/btc_fund_sources')).to be_routable }

    it { expect(delete('btc_fund_sources/1')).to be_routable }
  end
end
