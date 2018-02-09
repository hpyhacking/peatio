describe APIv2::Markets, type: :request do
  describe 'GET /api/v2/markets' do
    it 'should all available markets' do
      get '/api/v2/markets'
      expect(response).to be_success
      expect(response.body).to eq '[{"id":"btcusd","name":"BTC/USD"}]'
    end
  end
end
