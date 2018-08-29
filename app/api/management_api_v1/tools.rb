# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Tools < Grape::API
    desc 'Returns server time in seconds since Unix epoch.' do
      @settings[:scope] = :tools
    end
    post '/timestamp' do
      body timestamp: Time.now.iso8601
      status 200
    end
  end
end
