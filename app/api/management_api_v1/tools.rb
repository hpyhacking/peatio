module ManagementAPIv1
  class Tools < Grape::API
    desc 'Returns server time in seconds since Unix epoch.' do
      @settings[:scope] = :tools
    end
    post '/timestamp' do
      body timestamp: Time.now.to_i
      status 200
    end
  end
end
