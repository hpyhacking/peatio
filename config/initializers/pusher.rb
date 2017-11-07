Pusher.app_id  = ENV.fetch('PUSHER_APP', nil)
Pusher.key     = ENV.fetch('PUSHER_KEY', nil)
Pusher.secret  = ENV.fetch('PUSHER_SECRET', nil)
Pusher.host    = ENV.fetch('PUSHER_HOST', 'api.pusherapp.com')
Pusher.port    = ENV.fetch('PUSHER_PORT', 80)
Pusher.cluster = ENV.fetch('PUSHER_CLUSTER', 'eu')

