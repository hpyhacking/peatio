# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class PusherMember
    def process(payload)
      return unless (sn = Member.where(id: payload['member_id']).pluck(:sn).first)
      event = payload['event']
      data  = payload['data']
      Pusher["private-#{sn}"].trigger(event, data)
    end
  end
end
