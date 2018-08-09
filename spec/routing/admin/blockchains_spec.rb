# encoding: UTF-8
# frozen_string_literal: true

describe 'routes', type: :routing do
  let(:existing_blockchain) { Blockchain.first }
  let(:base_route) { '/admin/blockchains' }
  it 'routes to BlockchainsController' do
    expect(get: base_route).to be_routable
    expect(post: base_route).to be_routable
    expect(get: "#{base_route}/new").to be_routable
    expect(get: "#{base_route}/#{existing_blockchain.id}").to be_routable
    expect(put: "#{base_route}/#{existing_blockchain.id}").to be_routable
  end

  it 'doesn\'t routes to BlockchainsController' do
    expect(delete: "#{base_route}/#{existing_blockchain.id}").to_not be_routable
  end
end