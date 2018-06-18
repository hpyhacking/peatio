# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class MemberLevels < Grape::API
    desc 'Returns list of member levels and the privileges they provide.'
    get '/member_levels' do
      { deposit: { minimum_level: ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_DEPOSIT').to_i },
        withdraw: { minimum_level: ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_WITHDRAW').to_i },
        trading: { minimum_level: ENV.fetch('MINIMUM_MEMBER_LEVEL_FOR_TRADING').to_i } }
    end
  end
end
