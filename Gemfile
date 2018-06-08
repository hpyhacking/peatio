source 'https://rubygems.org'
#3 git repository needed i had forked
gem 'rails', '~> 4.0.12'
gem 'rails-i18n'

gem 'mysql2'
gem 'daemons-rails'
gem 'redis-rails'

gem 'rotp'
gem 'json'
gem 'jbuilder'
gem 'bcrypt-ruby', '~> 3.1.2'

gem 'doorkeeper', '~> 1.4.1'
gem 'omniauth', '~> 1.2.1'
gem 'omniauth-identity', '~> 1.1.1'
gem 'omniauth-weibo-oauth2', '~> 0.4.0'

gem 'figaro'
gem 'hashie'

gem 'aasm', '~> 3.4.0'
gem 'amqp', '~> 1.3.0'
gem 'bunny', '~> 1.2.1'
gem 'cancancan'
gem 'enumerize'
gem 'datagrid'
gem 'acts-as-taggable-on'
gem 'kaminari'
gem 'paranoid2'
gem 'active_hash'
gem 'http_accept_language'
gem "globalize", "~> 4.0.0"
gem 'paper_trail', '~> 3.0.1'
gem 'rails-observers'
gem 'country_select', '~> 2.1.0'

gem 'gon', '~> 5.2.0'
gem 'pusher'
gem 'eventmachine', '~> 1.0.4'
gem 'em-websocket', '~> 0.5.1'

gem 'simple_form', '~> 3.1.0'
gem 'slim-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem "jquery-rails"
gem "angularjs-rails"
gem 'bootstrap-sass', '~> 3.2.0.2'
gem 'bootstrap-wysihtml5-rails'
gem 'font-awesome-sass'
gem 'bourbon'
gem 'momentjs-rails'
gem 'eco'
gem 'browser', '~> 0.8.0'
gem 'rbtree'
gem 'liability-proof', '0.0.9'
gem 'whenever', '~> 0.9.2'
gem 'grape', '~> 0.7.0'
gem 'grape-entity', '~> 0.4.2'
gem 'grape-swagger', '~> 0.7.2'
gem 'rack-attack', '~> 3.0.0'
gem 'easy_table'
gem 'phonelib', '~> 0.3.5'
gem 'twilio-ruby', '~> 3.11'
# peatio/unread not exists any more, replace with itering/unread
#old gem 'unread', github: 'peatio/unread'
gem 'unread', github: 'itering/unread'
gem 'carrierwave', '~> 0.10.0'
gem 'simple_captcha2', require: 'simple_captcha'
gem 'rest-client', '~> 1.6.8'

group :development, :test do
# factory_girl has updated to factory_bot, so need change
#old gem 'factory_bot_rails'
  gem 'factory_bot_rails'
  gem 'factory_girl_rails'
  gem 'faker', '~> 1.4.3'
  gem 'mina'
#peatio/mina-slack not exists any longer,replaced with blockchaintech-au/mina-slack.
#old  gem 'mina-slack', github: 'peatio/mina-slack'
  gem 'mina-slack', github: 'blockchaintech-au/mina-slack'
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'quiet_assets'
  gem 'mails_viewer'
  gem 'timecop'
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'byebug'
end

group :test do
  gem 'database_cleaner'
  gem 'mocha', :require => false
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'poltergeist'

  # rspec-rails rely on test-unit if rails version less then 4.1.0
  # but test-unit has been removed from ruby core since 2.2.0
  gem 'test-unit'
end
