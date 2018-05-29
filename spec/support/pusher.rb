# encoding: UTF-8
# frozen_string_literal: true

module NullPusher
  def trigger(*)

  end

  def trigger_async(*)

  end
end

Pusher::Client.include NullPusher
Pusher::Channel.include NullPusher
