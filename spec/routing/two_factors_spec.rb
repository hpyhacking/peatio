require 'spec_helper'

describe 'two_factors' do
  it { expect(get('/two_factors/sms')).to be_routable }
end
