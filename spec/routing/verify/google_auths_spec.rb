require 'spec_helper'

describe 'google_auths' do
  describe 'get /verify/google_auth' do
    it { expect(get('/verify/google_auth')).to be_routable }
  end

  describe 'get /verify/google_auth/edit' do
    it { expect(get('/verify/google_auth/edit')).to be_routable }
  end

  describe 'put /verify/google_auth' do
    it { expect(put('/verify/google_auth')).to be_routable }
  end
end
