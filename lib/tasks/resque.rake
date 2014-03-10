require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] ||= '*'
end
