require_relative 'errors'

module APIv2
  class Mount < Grape::API
    prefix 'api'
    version 'v2', using: :path

    format :json
    default_format :json

    helpers ::APIv2::Helpers

    mount Orders
  end
end
