module APIv2
  class Mount < Grape::API
    prefix 'api'
    version 'v2', using: :path

    helpers Helpers

    mount Orders
  end
end
