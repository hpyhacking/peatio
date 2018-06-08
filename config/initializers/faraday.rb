# encoding: UTF-8
# frozen_string_literal: true

module Faraday
  class Env
    attr_reader :request_body
  end

  class Connection
    alias original_run_request run_request

    def run_request(method, url, body, headers, &block)
      original_run_request(method, url, body, headers, &block).tap do |response|
        response.env.instance_variable_set :@request_body, body if body
      end
    end
  end

  class Response
    def assert_success!
      return self if success?
      raise Faraday::Error, describe
    end

    def describe
      ["-- HTTP #{status} #{reason_phrase} --",
       "",
       "-- Request URL --",
       env.url.to_s,
       "",
       "-- Request Method --",
       env.method.to_s.upcase,
       "",
       "-- Request headers --",
       env.request_headers.tap { |x| x['Authorization'] = 'SECRET' if x['Authorization'].present? }.to_json,
       "",
       "-- Request body --",
       env.request_body.to_s,
       "",
       "-- Response headers --",
       env.response_headers.to_json,
       "",
       "-- Response body --",
       env.body.to_s,
       ""
      ].join("\n")
    end
  end
end
