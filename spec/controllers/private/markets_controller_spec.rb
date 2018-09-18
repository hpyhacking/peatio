# encoding: UTF-8
# frozen_string_literal: true

describe Private::MarketsController, type: :controller do
  let(:member) { create(:member, level: 3) }
  let(:token) { jwt_for(member) }

  context 'logged in user' do
    describe 'GET /markets/btcusd' do
      before { auth_get :show, data, token }

      it { expect(response.status).to eq 200 }
    end
  end

  context 'non-login user' do
    describe 'GET /markets/btcusd' do
      before { get :show, data }

      it { expect(response.status).to eq 200 }
      it { expect(assigns(:member)).to be_nil }
    end
  end

  describe 'ability to disable markets UI' do
    context 'when market UI is enabled' do
      before { ENV['DISABLE_MARKETS_UI'] = nil }
      it 'should return HTTP 200' do
        auth_get :show, data, token
        expect(response).to have_http_status(200)
      end
    end

    context 'when market UI is disabled' do
      before { ENV['DISABLE_MARKETS_UI'] = 'true'}
      after  { ENV['DISABLE_MARKETS_UI'] = nil }
      it 'should return HTTP 204' do
        auth_get :show, data, token
        expect(response).to have_http_status(204)
      end
    end
  end


  private

  def data
    {
      id: 'btcusd',
      market: 'btcusd',
      ask: 'btc',
      bid: 'usd',
    }
  end
end
