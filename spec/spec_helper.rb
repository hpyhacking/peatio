# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
ENV['ADMIN'] ||= 'admin@peatio.tech'
ENV['PUSHER_SECRET'] = 'fake'
ENV['PUSHER_CLIENT_KEY'] = 'fake'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/retry'
require 'webmock/rspec'

WebMock.allow_net_connect!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

%i[ google_oauth2 auth0 barong ].each do |provider|
  { provider:     provider.to_s,
    uid:          '1234567890',
    info:         { email: "johnsmith@#{provider.to_s.gsub(/_/, '-')}-provider.com" },
    credentials:  {}
  }.tap do |hash|
    hash.merge!(level: rand(1..3), state: %w[ pending active ].sample) if provider == :barong
    OmniAuth.config.add_mock(provider, hash)
  end
end

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
  config.include Capybara::DSL

  # See https://github.com/DatabaseCleaner/database_cleaner#rspec-with-capybara-example
  config.before :suite do
    FileUtils.rm_rf(File.join(__dir__, 'tmp', 'cache'))
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before :each do
    DatabaseCleaner.strategy = :truncation
  end

  config.before :each, type: :feature do
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test
    unless driver_shares_db_connection_with_specs
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.before :each do
    DatabaseCleaner.start
    AMQPQueue.stubs(:publish)
    KlineDB.stubs(:kline).returns([])
    I18n.locale = :en
    %i[ usd btc dash eth xrp trst].each { |ccy| FactoryBot.create(:currency, ccy) }
    %i[ btcusd dashbtc ].each { |market| FactoryBot.create(:market, market) }
  end

  config.after :each, type: :feature do
    page.driver.quit
  end

  config.append_after :each do
    DatabaseCleaner.clean
  end

  if Bullet.enable?
    config.before :each do
      Bullet.start_request
    end

    config.after :each do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end

  config.verbose_retry = true
  config.default_retry_count = 3
  config.display_try_failure_messages = true
  config.exceptions_to_retry = [Net::ReadTimeout, Capybara::CapybaraError]
end
