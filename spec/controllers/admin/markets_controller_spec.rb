# encoding: UTF-8
# frozen_string_literal: true

describe Admin::MarketsController, type: :controller do
  let(:member) { create(:admin_member) }
  let :attributes do
    { bid_unit:      'usd',
      bid_fee:       '0.003'.to_d,
      bid_precision: 8,
      ask_unit:      'eth',
      ask_fee:       '0.02'.to_d,
      ask_precision: 8,
      enabled:       true,
      position:      100 }
  end
  let(:existing_market) { Market.ordered.first }

  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates market with valid attributes' do
      expect do
        post :create, trading_pair: attributes
        expect(response).to redirect_to admin_markets_path
      end.to change(Market, :count)
      market = Market.ordered.last
      attributes.each { |k, v| expect(market.method(k).call).to eq v }
    end

    it 'doesn\'t create market if commodity pair already exists' do
      existing = Market.ordered.first
      params   = attributes.merge(bid_unit: existing.bid_unit, ask_unit: existing.ask_unit)
      expect do
        post :create, trading_pair: params
        expect(response).not_to redirect_to admin_markets_path
      end.not_to change(Market, :count)
    end
  end

  describe '#update' do
    let :new_attributes do
      { bid_unit:      'btc',
        bid_fee:       '0.002'.to_d,
        bid_precision: 7,
        ask_unit:      'xrp',
        ask_fee:       '0.05'.to_d,
        ask_precision: 7,
        enabled:       false,
        position:      200 }
    end

    let :final_attributes do
      new_attributes.merge \
        attributes.slice \
          :bid_unit,
          :ask_unit,
          :ask_precision,
          :bid_precision
    end

    before { request.env['HTTP_REFERER'] = '/admin/markets' }

    it 'updates market attributes' do
      post :create, trading_pair: attributes
      market = Market.ordered.last
      attributes.each { |k, v| expect(market.method(k).call).to eq v }
      post :update, trading_pair: new_attributes, id: market.id
      expect(response).to redirect_to admin_markets_path
      market.reload
      final_attributes.each { |k, v| expect(market.method(k).call).to eq v }
    end
  end

  describe '#destroy' do
    it 'doesn\'t support deletion of markets' do
      expect { delete :destroy, id: existing_market.id }.to raise_error(ActionController::UrlGenerationError)
    end
  end

  describe 'routes' do
    let(:base_route) { '/admin/markets' }
    it 'routes to MarketsController' do
      expect(get: base_route).to be_routable
      expect(post: base_route).to be_routable
      expect(get: "#{base_route}/new").to be_routable
      expect(get: "#{base_route}/#{Market.ordered.first.id}").to be_routable
      expect(put: "#{base_route}/#{Market.ordered.first.id}").to be_routable
    end

    it 'doesn\'t routes to CurrenciesController' do
      expect(delete: "#{base_route}/#{existing_market.id}").to_not be_routable
    end
  end
end
