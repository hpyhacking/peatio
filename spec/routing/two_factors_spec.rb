require 'spec_helper'

describe 'two_factors' do
  it { expect(get('/two_factors/sms')).to be_routable }
  it { expect(get('/two_factors')).to be_routable }
  it { expect(put('/two_factors/sms')).to be_routable }
end
