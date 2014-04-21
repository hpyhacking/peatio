require 'spec_helper'

describe 'private' do

  describe 'get /two_factors/app' do
    it { expect(get('/two_factors/app')).to be_routable }
    it { expect(get('/two_factors/app')).to route_to \
      controller: 'private/two_factors',
      action: 'show',
      id: 'app'
    }
  end

  describe 'get /two_factors/app/edit' do
    it { expect(get('/two_factors/app/edit')).to be_routable }
    it { expect(get('/two_factors/app/edit')).to route_to \
      controller: 'private/two_factors',
      action: 'edit',
      id: 'app'
    }
  end

  describe 'put /two_factors/app' do
    it { expect(put('/two_factors/app')).to be_routable }
  end
end
