describe Admin::MarketsController, type: :controller do
  let(:member) { create(:admin_member) }
  let(:valid_market_attributes) do
    { bid_unit: :usd,
      bid_fee: 0.1,
      bid_precision: 4,
      ask_unit: :eth,
      ask_fee: 0.2,
      ask_precision: 4,
      visible: true,
      position: 100 }
  end
  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates market with valid attributes' do
      expect do
        post :create, trading_pair: valid_market_attributes
        expect(response).to redirect_to admin_markets_path
      end.to change(Market, :count)
    end

    it 'doesn\'t create market if commodity pair already exists' do
      existing = Market.first
      params   = valid_market_attributes.merge(bid_unit: existing.bid_unit, ask_unit: existing.ask_unit)
      expect do
        post :create, trading_pair: params
        expect(response).not_to redirect_to admin_markets_path
      end.not_to change(Market, :count)
    end
  end

  describe '#update' do
    let(:existing_market) { Market.first }
    before { valid_market_attributes.except!(:bid_unit, :ask_unit) }
    before { request.env['HTTP_REFERER'] = '/admin/markets' }

    it 'updates market attributes' do
      post :update, trading_pair: valid_market_attributes, id: existing_market.id
      expect(response).to redirect_to admin_markets_path
      valid_market_attributes.each do |k, v|
        expect(existing_market.reload.method(k).call).to eq v
      end
    end

    it 'doesn\'t update units and ID' do
      post :update, trading_pair: { bid_unit: :btc }, id: existing_market.id
      old_id = existing_market.id
      expect(response).to redirect_to '/admin/markets'
      expect(existing_market.reload.bid_unit).not_to eq :btc
      expect(existing_market.reload.id).to eq old_id
    end
  end

  describe '#destroy' do
    let(:existing_market) { Market.first }

    it 'doesn\'t support deletion of markets' do
      expect { delete :destroy, id: existing_market.id }.to raise_error(ActionController::UrlGenerationError)
    end
  end
end
