# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class PusherMember
    def process(payload)
      return unless (member = Member.find_by_id(payload['member_id']))
      event = payload['event']
      data  = payload['data']
      Pusher["private-#{member.sn}"].trigger(event, data)
    end
  end
end
