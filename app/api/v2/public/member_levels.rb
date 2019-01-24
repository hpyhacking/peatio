# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Public
      class MemberLevels < Grape::API
        desc 'Returns hash of minimum levels and the privileges they provide.'
        get '/member-levels' do
          { deposit: { minimum_level: ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_DEPOSIT').to_i },
            withdraw: { minimum_level: ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_WITHDRAW').to_i },
            trading: { minimum_level: ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_TRADING').to_i } }
        end
      end
    end
  end
end
