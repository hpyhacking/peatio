# encoding: UTF-8
# frozen_string_literal: true

require "peatio/ranger/events"

module Workers
  module AMQP
    class PusherMember < Base
      def process(payload)
        return unless (uid = Member.where(id: payload["member_id"]).first.uid)

        event = payload["event"]
        data = payload["data"]

        Peatio::Ranger::Events.publish("private", uid, event, data)
      end
    end
  end
end
