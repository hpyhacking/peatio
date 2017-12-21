Pusher.app_id  = ENV['PUSHER_APP']
Pusher.key     = ENV['PUSHER_KEY']
Pusher.secret  = ENV['PUSHER_SECRET']
Pusher.host    = ENV.fetch('PUSHER_HOST', 'api.pusherapp.com')
Pusher.port    = ENV.fetch('PUSHER_PORT', 80).to_i
Pusher.cluster = ENV.fetch('PUSHER_CLUSTER', 'eu')
