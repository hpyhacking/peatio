# frozen_string_literal: true

describe API::V2::Public::Config, type: :request do
	before(:each) { clear_redis }
  describe 'GET /api/v2/public/config' do
		it 'return public config' do
			get '/api/v2/public/config'
			expect(response).to be_successful

      result = JSON.parse(response.body)
			expect(result['currencies'].count).to eq Currency.active.count
			expect(result['trading_fees'].count).to eq TradingFee.all.count
			expect(result['markets'].count).to eq Market.active.count
			expect(result['withdraw_limits'].count).to eq WithdrawLimit.all.count
		end
	end
end
