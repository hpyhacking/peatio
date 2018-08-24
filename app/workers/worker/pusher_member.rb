# encoding: UTF-8
# frozen_string_literal: true

require "peatio/mq/events"

module Worker
  class PusherMember
    def process(payload)
      return unless (sn = Member.where(id: payload["member_id"]).pluck(:sn).first)

      event = payload["event"]
      data = payload["data"]

      Peatio::MQ::Events.publish("private", sn, event, data)
    end
  end
end
