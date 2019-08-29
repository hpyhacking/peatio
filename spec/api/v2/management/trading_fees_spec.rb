# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::TradingFees, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_trading_fees:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
      }
  end

  describe '/fee_schedule/trading_fees' do
    def request
      post_json '/api/v2/management/fee_schedule/trading_fees', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) {}
    let(:signers) { %i[alex jeff] }

    before do
      create(:trading_fee, maker: 0.0005, taker: 0.001, market_id: :btcusd, group: 'vip-0')
      create(:trading_fee, maker: 0.0008, taker: 0.001, market_id: :any, group: 'vip-0')
      create(:trading_fee, maker: 0.001, taker: 0.0012, market_id: :btcusd, group: :any)
    end

    it 'returns all trading fees tables' do
      request
      expect(response).to have_http_status(200)
      expect(response.headers.fetch('Total')).to eq('4')
    end

    context 'group: vip-0, market: btcusd' do
      let(:data) { { group: 'vip-0', market_id: 'btcusd' } }
      it 'returns trading fee with btcusd market_id and vip-0 group' do
        request
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body).first['maker']).to eq('0.0005')
        expect(JSON.parse(response.body).first['taker']).to eq('0.001')
        expect(JSON.parse(response.body).first['group']).to eq('vip-0')
        expect(JSON.parse(response.body).first['market_id']).to eq('btcusd')
        expect(response.headers.fetch('Total')).to eq('1')
      end
    end

    context 'group: any, market: btcusd' do
      let(:data) { { group: 'any', market_id: 'btcusd' } }
      it 'returns trading fee with btcusd market_id and `any` group' do
        request
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body).first['maker']).to eq('0.001')
        expect(JSON.parse(response.body).first['taker']).to eq('0.0012')
        expect(JSON.parse(response.body).first['group']).to eq('any')
        expect(JSON.parse(response.body).first['market_id']).to eq('btcusd')
        expect(response.headers.fetch('Total')).to eq('1')
      end
    end

    context 'group: vip-0, market: any' do
      let(:data) { { group: 'vip-0', market_id: 'any' } }
      it 'returns trading fee with btcusd market_id and `any` group' do
        request
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body).first['maker']).to eq('0.0008')
        expect(JSON.parse(response.body).first['taker']).to eq('0.001')
        expect(JSON.parse(response.body).first['group']).to eq('vip-0')
        expect(JSON.parse(response.body).first['market_id']).to eq('any')
        expect(response.headers.fetch('Total')).to eq('1')
      end
    end
  end
end
