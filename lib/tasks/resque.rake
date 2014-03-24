require 'resque/tasks'

namespace :resque do

  task :setup => :environment do
    ENV['QUEUE'] ||= 'coin,examine'
    raise "Never start worker with QUEUE=* !!!" if ENV['QUEUE'] == '*'
  end

  desc "Start matching engine"
  task :matching => [ :preload, :setup ] do
    require 'resque'

    begin
      worker = Resque::Worker.new('matching')
      if ENV['LOGGING'] || ENV['VERBOSE']
        worker.verbose = ENV['LOGGING'] || ENV['VERBOSE']
      end
      if ENV['VVERBOSE']
        worker.very_verbose = ENV['VVERBOSE']
      end
      worker.term_timeout = ENV['RESQUE_TERM_TIMEOUT'] || 4.0
      worker.term_child = ENV['TERM_CHILD']
      worker.run_at_exit_hooks = ENV['RUN_AT_EXIT_HOOKS']
      worker.cant_fork = true
    rescue Resque::NoQueueError
      abort "set QUEUE env var, e.g. $ QUEUE=critical,high rake resque:work"
    end

    if ENV['BACKGROUND']
      unless Process.respond_to?('daemon')
          abort "env var BACKGROUND is set, which requires ruby >= 1.9"
      end
      Process.daemon(true, true)
    end

    if ENV['PIDFILE']
      File.open(ENV['PIDFILE'], 'w') { |f| f << worker.pid }
    end

    worker.log "Starting worker #{worker}"

    worker.work(ENV['INTERVAL'] || 0.5) # interval, will block
  end

end
