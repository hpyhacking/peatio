# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Members < Grape::API
    helpers APIv2::NamedParams

    before { authenticate! }

    desc 'Get your profile and accounts info.', scopes: %w[ profile ]
    get '/members/me' do
      present current_user, with: APIv2::Entities::Member
    end
  end
end
