require 'spec_helper'

describe '/admin/members/1/two_factors' do
  let(:url) { '/admin/members/1/two_factors/1' }
  it { expect(delete: url).to be_routable }
  it { expect(delete: url).to route_to \
       controller: 'admin/two_factors',
       action: 'destroy',
       member_id: '1',
       id: '1'
  }
end
