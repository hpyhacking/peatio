require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/slack/tasks'
require 'mina/whenever'

case ENV['to']
when 'demo'
  set :domain, 'demo.peat.io'
  set :branch, 'stable'
else
  set :domain, 'stg.peat.io'
  set :branch, ENV['branch'] || 'master'
end

set :deploy_to, '/var/www/peatio'
set :repository, 'https://github.com/peatio/peatio.git'

set :shared_paths, [
  'config/database.yml',
  'config/application.yml',
  'config/currencies.yml',
  'config/markets.yml',
  'config/amqp.yml',
  'config/deposit_channels.yml',
  'config/withdraw_channels.yml',
  'tmp',
  'log'
]

task :environment do
  invoke :'rbenv:load'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue! %[touch "#{deploy_to}/shared/config/currencies.yml"]
  queue! %[touch "#{deploy_to}/shared/config/application.yml"]
  queue! %[touch "#{deploy_to}/shared/config/markets.yml"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      invoke :'unicorn:upgrade'
    end
  end
  invoke :'slack:finish'
end

desc "Production Log"
task :prodlog => :environment do
  queue echo_cmd("cd #{deploy_to}/current && tail -f log/production.log")
end

desc "Rails Console"
task :console => :environment do
  queue echo_cmd("cd #{deploy_to}/current && RAILS_ENV=production bundle exec rails console")
end

desc "Upgrade Unicorn"
task :'unicorn:upgrade' => :environment do
  queue 'service unicorn_peatio upgrade && echo Upgrade Unicorn DONE!!!'
end

desc "Start Daemons"
task :'daemons:start' => :environment do
  queue "cd #{deploy_to}/current && RAILS_ENV=production bundle exec ./bin/rake daemons:start && echo Daemons START DONE!!!"
end

desc "Stop Daemons"
task :'daemons:stop' => :environment do
  queue "cd #{deploy_to}/current && RAILS_ENV=production bundle exec ./bin/rake daemons:stop && echo Daemons STOP DONE!!!"
end

desc "Query Daemons"
task :'daemons:status' => :environment do
  queue "cd #{deploy_to}/current && RAILS_ENV=production bundle exec ./bin/rake daemons:status"
end

desc "Generate liability proof"
task 'solvency:liability_proof' do
  queue "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake solvency:liability_proof"
end
