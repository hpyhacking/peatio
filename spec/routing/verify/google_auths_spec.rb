require 'spec_helper'

describe 'google_auths' do
  describe 'get /verify/google_auths/app' do
    it { expect(get('/verify/google_auths/app')).to be_routable }
    it { expect(get('/verify/google_auths/app')).to route_to \
         controller: 'verify/google_auths',
         action: 'show',
         id: 'app'
    }
  end

  describe 'get /verify/google_auths/app/edit' do
    it { expect(get('/verify/google_auths/app/edit')).to be_routable }
    it { expect(get('/verify/google_auths/app/edit')).to route_to \
         controller: 'verify/google_auths',
         action: 'edit',
         id: 'app'
    }
  end

  describe 'put /verify/google_auths/app' do
    it { expect(put('/verify/google_auths/app')).to be_routable }
  end
end
