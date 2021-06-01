# frozen_string_literal: true

module API
  module V2
    module Account
      class Members < Grape::API
        desc 'Returns current member',
          success: API::V2::Entities::Member
        get '/members/me' do
          present current_user, with: API::V2::Entities::Member
        end
      end
    end
  end
end
