# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class Tools < Grape::API
        desc 'Get server current time, in seconds since Unix epoch.'
        get "/timestamp" do
          ::Time.now.iso8601
        end
      end
    end
  end
end
