require_relative 'errors'

module APIv2
  class Mount < Grape::API
    prefix 'api'
    version 'v2', using: :path

    format :json
    default_format :json

    helpers Helpers

    mount Orders
  end
end
