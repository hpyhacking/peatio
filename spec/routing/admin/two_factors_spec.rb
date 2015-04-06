require 'spec_helper'

describe '/admin/members/1/two_factors' do
  let(:url) { '/admin/members/1/two_factors/1' }
  it { expect(delete: url).to be_routable }
end
