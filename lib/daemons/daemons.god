# encoding: UTF-8
# frozen_string_literal: true

RAILS_ENV  = ENV.fetch('RAILS_ENV', 'development')
RAILS_ROOT = File.expand_path('../../..', __FILE__)

require 'shellwords'

# Create non-default log/daemons directory.
require 'fileutils'
FileUtils.mkdir_p "#{RAILS_ROOT}/log/daemons"

def daemon(name, options = {})
  God.watch do |w|
    command        = "bundle exec ruby lib/daemons/#{options.fetch(:script)}"
    command       += ' ' + options[:arguments].join(' ') if options.key?(:arguments)
    filesafe_name  = name.gsub(/\W/, '_')

    w.name  = name
    w.start = command
    w.dir   = RAILS_ROOT
    w.env   = { 'RAILS_ENV' => RAILS_ENV, 'RAILS_ROOT' => RAILS_ROOT }

    # Peatio has lot of dependencies which take some time to load ever on fast disks.
    # God, by default, doesn't wait before resuming normal monitoring operations.
    # So we need to adjust this variable so God will wait 10 seconds on start/restart operations.
    w.grace = 10.seconds

    # God will send SIGTERM to the process and wait 10 seconds.
    # If process has still not exited it will be killed by sending SIGKILL.
    w.stop_signal  = 'TERM'
    w.stop_timeout = 10.seconds

    # God will always keep process running unless it was manually terminated.
    w.keepalive

    # In production Docker environment logs go to /dev/stdout.
    if RAILS_ENV == 'production'
      w.log_cmd = "#{RAILS_ROOT}/bin/logger #{name.shellescape}"
    #
    # In non-production environment logs go to files.
    else
      w.log = "#{RAILS_ROOT}/log/daemons/#{filesafe_name}.log"
    end

    # Allow customizations.
    yield(w) if block_given?
  end
end

daemon 'amqp:deposit_collection',
       script:   'amqp_daemon.rb',
       arguments: %w[ deposit_collection ]

daemon 'amqp:deposit_collection_fees',
       script:   'amqp_daemon.rb',
       arguments: %w[ deposit_collection_fees ]

daemon 'amqp:deposit_coin_address',
       script:   'amqp_daemon.rb',
       arguments: %w[ deposit_coin_address ]

daemon 'amqp:slave_book',
       script:   'amqp_daemon.rb',
       arguments: %w[ slave_book  ]

daemon 'amqp:market_ticker',
       script:   'amqp_daemon.rb',
       arguments: %w[ market_ticker ]

daemon 'amqp:matching',
       script:   'amqp_daemon.rb',
       arguments: %w[ matching ]

daemon 'amqp:order_processor',
       script:   'amqp_daemon.rb',
       arguments: %w[ order_processor ]

daemon 'amqp:pusher_market',
       script:   'amqp_daemon.rb',
       arguments: %w[ pusher_market ]

daemon 'amqp:pusher_member',
       script:   'amqp_daemon.rb',
       arguments: %w[ pusher_member ]

daemon 'amqp:trade_executor',
       script:   'amqp_daemon.rb',
       arguments: %w[ trade_executor ]

daemon 'amqp:withdraw_coin',
       script:   'amqp_daemon.rb',
       arguments: %w[ withdraw_coin ]

Dir.glob "#{File.dirname(__FILE__)}/**/*.rb" do |file|
  script = File.basename(file)
  next if %w[ amqp_daemon.rb ].include?(script)
  daemon File.basename(script, '.*'), script: script
end
