# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Public::Tools, type: :request do
  describe '/timestamp' do
    it 'returns current time in seconds' do
      now = Time.now
      get '/api/v2/public/timestamp'
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to be_between(now.iso8601, (now + 1).iso8601)
    end
  end

  describe '/health' do
    it 'returns successful liveness probe' do
      get '/api/v2/public/health/alive'
      expect(response).to be_successful
    end

    it 'returns failed liveness probe' do
      Market.stubs(:connected?).returns(false)

      get '/api/v2/public/health/alive'
      expect(response).to have_http_status(503)
    end

    it 'returns successful readiness probe' do
      get '/api/v2/public/health/ready'
      expect(response).to be_successful
    end

    it 'returns failed readiness probe' do
      Bunny.stubs(:run).returns(false)

      get '/api/v2/public/health/alive'
      expect(response).to have_http_status(503)
    end
  end
end
