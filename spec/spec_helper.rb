# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
ENV['ADMIN'] ||= 'admin@peatio.tech'
require File.expand_path('../../config/environment', __FILE__)
require 'database_cleaner'
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

if ENV['SELENIUM_HOST'].present?
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(
      app,
      url: "http://#{ENV['SELENIUM_HOST']}:#{ENV['SELENIUM_PORT']}/wd/hub",
      browser: :remote,
      desired_capabilities: :chrome
    )
  end

  Capybara.app_host = "http://#{ENV['TEST_APP_HOST']}:#{ENV['TEST_APP_PORT']}"
  Capybara.javascript_driver = :chrome
  Capybara.run_server = false
else
  Capybara.default_driver    = :selenium_chrome_headless
  Capybara.javascript_driver = :selenium_chrome_headless
end

Capybara.default_max_wait_time = 25

%i[ google_oauth2 auth0 ].each do |provider|
  { 'provider' => provider.to_s,
    'uid'      => '1234567890',
    'info'     => { 'name' => 'John Smith',
                    'email' => "johnsmith@#{provider.to_s.gsub(/_/, '-')}-provider.com" }
  }.tap { |hash| OmniAuth.config.add_mock(provider, hash) }
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

  config.include FactoryBot::Syntax::Methods
  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL

  config.before(:each, type: :feature) do
    Capybara.current_session.driver.browser.manage.window.resize_to(1024, 768)
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    DatabaseCleaner.start

    FileUtils.rm_rf(File.join(__dir__, 'tmp', 'cache'))
    AMQPQueue.stubs(:publish)
    KlineDB.stubs(:kline).returns([])

    I18n.locale = :en
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
