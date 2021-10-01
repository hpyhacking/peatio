# encoding: UTF-8
# frozen_string_literal: true

require 'base64'
require 'openssl'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
ENV['EVENT_API_JWT_PRIVATE_KEY'] ||= Base64.urlsafe_encode64(OpenSSL::PKey::RSA.generate(2048).to_pem)
ENV['PEATIO_JWT_PRIVATE_KEY'] ||= Base64.urlsafe_encode64(OpenSSL::PKey::RSA.generate(2048).to_pem)
ENV['WITHDRAW_ADMIN_APPROVE'] = 'true'

# We remove lib/peatio.rb from LOAD_PATH because of conflict with peatio gem.
# lib/peatio.rb is added to LOAD_PATH later after requiring gems.
# https://relishapp.com/rspec/rspec-core/v/2-6/docs/command-line
$LOAD_PATH.delete_if { |p| File.expand_path(p) == File.expand_path('./lib') }

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/retry'
require 'webmock/rspec'
require 'cancan/matchers'

WebMock.allow_net_connect!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

Rails.application.load_tasks

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.filter_run_when_matching :focus

  config.include FactoryBot::Syntax::Methods
  config.include Rails.application.routes.url_helpers

  # See https://github.com/DatabaseCleaner/database_cleaner#rspec-with-capybara-example
  config.before(:suite) do
    FileUtils.rm_rf(File.join(__dir__, 'tmp', 'cache'))
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, clean_database_with_truncation: true) do
    DatabaseCleaner.strategy = :truncation, { only: %w[orders trades] }
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each) do
    DatabaseCleaner.start
    AMQP::Queue.stubs(:publish)
    KlineDB.stubs(:kline).returns([])
    Currency.any_instance.stubs(:price).returns(1.to_d)
    %w[fiat eth-kovan eth-rinkeby btc-testnet].each { |blockchain| FactoryBot.create(:blockchain, blockchain) }
    %i[usd eur btc eth trst ring].each { |ccy| FactoryBot.create(:currency, ccy) }
    %i[usd_network eur_network btc_network eth_network trst_network ring_network].each do |blockchain_currency|
      FactoryBot.create(:blockchain_currency, blockchain_currency)
    end

    %i[ eth_deposit eth_hot eth_warm eth_fee
        trst_deposit trst_hot
        btc_hot btc_deposit ].each { |ccy| FactoryBot.create(:wallet, ccy) }
    %i[btcusd btceth btceth_qe].each { |market| FactoryBot.create(:market, market) }
    %w[101 102 201 202 211 212 301 302 401 402].each { |ac_code| FactoryBot.create(:operations_account, ac_code)}
    FactoryBot.create(:trading_fee, market_id: :any, group: :any, maker: 0.0015, taker: 0.0015)
    FactoryBot.create(:withdraw_limit)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.verbose_retry = true
  config.default_retry_count = 3
  config.display_try_failure_messages = true
  config.exceptions_to_retry = [Net::ReadTimeout]

  if Bullet.enable?
    config.before(:each) { Bullet.start_request }
    config.after :each do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end
