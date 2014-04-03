module APIv2
  class Mount < Grape::API
    prefix 'api'

    version 'v2', using: :path

    mount Orders
  end
end
