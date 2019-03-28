# encoding: UTF-8
# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo_slug| "https://github.com/#{repo_slug}" }

gem 'rails', '~> 5.0.7'
gem 'puma', '~> 3.12.0'
gem 'mysql2', '~> 0.4.10'
gem 'redis-rails', '~> 5.0.2'
gem 'jbuilder', '~> 2.7.0'
gem 'figaro', '~> 1.1.1'
gem 'hashie', '~> 3.6.0'
gem 'aasm', '~> 5.0.0'
gem 'bunny', '~> 2.14.1'
gem 'cancancan', '~> 2.3.0'
gem 'enumerize', '~> 2.2.2'
gem 'kaminari', '~> 1.1.1'
gem 'api-pagination', '~> 4.8.2'
gem 'sassc-rails', '~> 2.1.0'
gem 'coffee-rails', '~> 4.2.2'
gem 'uglifier', '~> 4.1.20'
gem 'jquery-rails', '~> 4.3.3'
gem 'bootstrap', '~> 4.3.1'
gem 'font-awesome-sass', '~> 5.6.1'
gem 'rbtree', '~> 0.4.2'
gem 'grape', '~> 1.1.0'
gem 'grape-entity', '~> 0.7.1'
gem 'grape-swagger', '~> 0.30.1'
gem 'grape-swagger-ui', '~> 2.2.8'
gem 'grape-swagger-entity', '~> 0.2.5'
gem 'grape_logging', '~> 1.8.0'
gem 'rack-attack', '~> 5.4.2'
gem 'easy_table', '~> 0.0.10'
gem 'faraday', '~> 0.15.4'
gem 'jwt', '~> 2.1.0'
gem 'email_validator', '~> 1.6.0'
gem 'validate_url', '~> 1.0.4'
gem 'clipboard-rails', '~> 1.7.1'
gem 'god', '~> 0.13.7', require: false
gem 'mini_racer', '~> 0.2.4', require: false
gem 'arel-is-blank', '~> 1.0.0'
gem 'sentry-raven', '~> 2.9.0', require: false
gem 'memoist', '~> 0.16.0'
gem 'method-not-implemented', '~> 1.0.1'
gem 'passgen', '~> 1.0.2'
gem 'validates_lengths_from_database', '~> 0.7.0'
gem 'jwt-multisig', '~> 1.0.0'
gem 'cash-addr', '~> 0.2.0', require: 'cash_addr'
gem 'digest-sha3', '~> 1.1.0'
gem 'scout_apm', '~> 2.4', require: false
gem 'peatio', '~> 0.4.5'
gem 'rack-cors', '~> 1.0.2', require: false
gem 'env-tweaks', '~> 1.0.0'
gem 'vault', '~> 0.12', require: false

group :development, :test do
  gem 'bump',         '~> 0.7'
  gem 'faker',        '~> 1.8'
  gem 'pry-byebug',   '~> 3.7'
  gem 'bullet',       '~> 5.9'
  gem 'grape_on_rails_routes', '~> 0.3.2'
end

group :development do
  gem 'annotate',   '~> 2.7.4'
  gem 'ruby-prof',  '~> 0.17.0', require: false
end

group :test do
  gem 'rspec-rails',         '~> 3.8'
  gem 'rspec-retry',         '~> 0.6'
  gem 'webmock',             '~> 3.5'
  gem 'database_cleaner',    '~> 1.7'
  gem 'mocha',               '~> 1.8', require: false
  gem 'factory_bot_rails',   '~> 5.0'
  gem 'timecop',             '~> 0.9'
  gem 'rubocop-rspec',       '~> 1.32', require: false
end

# Load gems from Gemfile.plugin.
Dir.glob File.expand_path('../Gemfile.plugin', __FILE__) do |file|
  eval_gemfile file
end
