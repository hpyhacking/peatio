require 'spec_helper'

describe 'google_auths' do
  describe 'get /verify/google_auth' do
    it { expect(get('/verify/google_auth')).to route_to \
         controller: 'verify/google_auths',
         action: 'show'
    }
  end

  describe 'get /verify/google_auth/edit' do
    it { expect(get('/verify/google_auth/edit')).to route_to \
         controller: 'verify/google_auths',
         action: 'edit'
    }
  end

  describe 'put /verify/google_auth' do
    it { expect(put('/verify/google_auth')).to route_to \
         controller: 'verify/google_auths',
         action: 'update'
    }
  end
end
