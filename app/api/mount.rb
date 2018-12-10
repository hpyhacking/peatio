module API
  class Mount < Grape::API
    PREFIX = '/api'

    cascade false

    mount API::V2::Mount => API::V2::Mount::API_VERSION
  end
end
