# frozen_string_literal: true

describe API::V2::Account::Portfolio, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

  describe 'GET /api/v2/account/portfolio' do
    let!(:market) { create(:market, :ethusd) }
    let(:btcusd_bid) do
      create(
        :order_bid,
        :btcusd,
        price: '8200'.to_d,
        volume: '0.1',
        member: member
      )
    end

    let(:ethusd_bid) do
      create(
        :order_bid,
        :btcusd,
        market_id: :ethusd,
        price: '300'.to_d,
        volume: '1.2',
        member: member
      )
    end

    let(:btcusd_ask) do
      create(
        :order_ask,
        :btcusd,
        price: '8200'.to_d,
        volume: '0.1',
        member: member
      )
    end

    let(:ethusd_ask) do
      create(
        :order_ask,
        :btcusd,
        market_id: :ethusd,
        price: '300'.to_d,
        volume: '1.2',
        member: member
      )
    end

    let!(:ethusd_trade) { create(:trade, :btcusd, price: 300, amount: 1.2, market_id: :ethusd, maker_order: ethusd_ask, taker_order: ethusd_bid) }
    let!(:btcusd_trade) { create(:trade, :btcusd, price: 8200, amount: 0.1, maker_order: btcusd_ask, taker_order: btcusd_bid) }

    let(:btcusd_pa) { { 'base_unit' => 'btc', 'price' => '8200.0', 'total' => '820.0' } }
    let(:ethusd_pa) { { 'base_unit' => 'eth', 'price' => '300.0', 'total' => '360.0' } }

    it 'returns error if invalid quote unit' do
      api_get '/api/v2/account/portfolio?quote_unit=xrp', token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('account.portfolio.quote_unit_doesnt_exist')
    end

    it 'returns [] for markets without user trade activity' do
      api_get '/api/v2/account/portfolio?quote_unit=eth', token: token
      expect(response).to be_successful
      expect(response_body).to eq([])
    end

    it 'returns price of acquisition and total for markets with usd quote' do
      api_get '/api/v2/account/portfolio?quote_unit=usd', token: token
      expect(response).to be_successful
      [btcusd_pa, ethusd_pa].each do |bu|
        expect(response_body.find { |pa| pa['base_unit'] == bu['base_unit'] }).to eq bu
      end
    end
  end
end
