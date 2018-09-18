module API
  class Mount < Grape::API
    cascade false

    mount API::V2::Mount => '/v2'
  end
end