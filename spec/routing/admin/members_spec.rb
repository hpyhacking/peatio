require 'spec_helper'

describe '/admin/members' do
  context 'deactive two_factor auths' do
    it { expect(put('/admin/members/1/deactive_two_factor')).to be_routable }
    it { expect(put('/admin/members/1/deactive_two_factor')).to route_to \
         controller: 'admin/members',
         action: 'deactive_two_factor',
         id: '1'
    }
  end
end
