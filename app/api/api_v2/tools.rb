# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Tools < Grape::API
    desc 'Get server current time, in seconds since Unix epoch.'
    get "/timestamp" do
      ::Time.now.iso8601
    end
  end
end
