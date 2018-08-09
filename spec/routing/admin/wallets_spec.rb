# encoding: UTF-8
# frozen_string_literal: true

describe 'routes', type: :routing do
  describe 'routes' do
    let(:existing_wallet) { Wallet.first }
    let(:base_route) { '/admin/wallets' }
    it 'routes to WalletsController' do
      expect(get: base_route).to be_routable
      expect(post: base_route).to be_routable
      expect(get: "#{base_route}/new").to be_routable
      expect(get: "#{base_route}/#{existing_wallet.id}").to be_routable
      expect(put: "#{base_route}/#{existing_wallet.id}").to be_routable
    end

    it 'doesn\'t routes to WalletsController' do
      expect(delete: "#{base_route}/#{existing_wallet.id}").to_not be_routable
    end
  end
end