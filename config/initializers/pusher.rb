# encoding: UTF-8
# frozen_string_literal: true

Pusher.app_id = ENV.fetch('PUSHER_APP')
Pusher.key    = ENV.fetch('PUSHER_CLIENT_KEY')
Pusher.secret = ENV.fetch('PUSHER_SECRET')
Pusher.host   = ENV.fetch('PUSHER_HOST')
Pusher.scheme = ENV.fetch('PUSHER_SCHEME')
Pusher.port   = ENV.fetch('PUSHER_PORT')
