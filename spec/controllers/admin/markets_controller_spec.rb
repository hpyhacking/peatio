# encoding: UTF-8
# frozen_string_literal: true

describe Admin::MarketsController, type: :controller do
  let(:member) { create(:admin_member) }
  before(:each) { inject_authorization!(member) }
  let :attributes do
    { quote_currency:     'usd',
      price_precision:    4,
      base_currency:      'eth',
      maker_fee:          '0.003'.to_d,
      taker_fee:          '0.02'.to_d,
      min_amount:         '0.02'.to_d,
      min_price:          '0.02'.to_d,
      amount_precision:   4,
      state:              'enabled',
      position:           100 }
  end
  let(:existing_market) { Market.ordered.first }

  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates market with valid attributes' do
      expect do
        post :create, params: { trading_pair: attributes }
        expect(response).to redirect_to admin_markets_path
      end.to change(Market, :count)
      market = Market.ordered.last
      attributes.each { |k, v| expect(market.method(k).call).to eq v }
    end

    it 'doesn\'t create market if commodity pair already exists' do
      existing = Market.ordered.first
      params   = attributes.merge(quote_currency: existing.quote_currency, base_currency: existing.base_currency)
      expect do
        post :create, params: { trading_pair: params }
        expect(response).not_to redirect_to admin_markets_path
      end.not_to change(Market, :count)
    end
  end

  describe '#update' do
    let :new_attributes do
      { quote_currency:         'btc',
        bid_fee:          '0.002'.to_d,
        price_precision:    7,
        base_currency:         'eth',
        ask_fee:          '0.05'.to_d,
        min_amount:       '0.02'.to_d,
        amount_precision: 7,
        state:            :disabled,
        position:         200 }
    end

    let :final_attributes do
      new_attributes.merge \
        attributes.slice \
          :quote_currency,
          :base_currency,
          :amount_precision,
          :price_precision
    end

    before { request.env['HTTP_REFERER'] = '/admin/markets' }

    xit 'updates market attributes' do
      post :create, params: { trading_pair: attributes }
      market = Market.ordered.last
      attributes.each { |k, v| expect(market.method(k).call).to eq v }
      post :update, params: { trading_pair: new_attributes, id: market.id }
      expect(response).to render_template admin_markets_path
      market.reload
      final_attributes.each { |k, v| expect(market.method(k).call).to eq v }
    end
  end

  describe '#destroy' do
    it 'doesn\'t support deletion of markets' do
      expect { delete :destroy, params: { id: existing_market.id } }.to raise_error(ActionController::UrlGenerationError)
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
