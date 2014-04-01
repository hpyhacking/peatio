RAILS_ENV=production PIDFILE=./log/resque.pid BACKGROUND=yes bundle exec rake environment resque:matching
RAILS_ENV=production PIDFILE=./log/other_resque.pid BACKGROUND=yes QUEUE=coin,examine,mailer bundle exec rake environment resque:work
