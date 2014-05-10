require 'spec_helper'

describe 'refresh_two_factors' do
  it { expect(get('/refresh_two_factors/sms')).to be_routable }
end
