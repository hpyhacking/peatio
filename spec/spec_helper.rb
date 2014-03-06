# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ENV["ADMIN"] ||= 'admin@peatio.dev'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/poltergeist'
require 'benchmark'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

I18n.locale = :en

Capybara.register_driver :poltergeist do |app|
  options = {:js_errors => false, :debug => false, :logger => nil, :phantomjs_logger => nil}
  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.javascript_driver = :poltergeist

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
  config.order = "random"

  # Exclude :performance tagged specs by default
  config.filter_run_excluding performance: true

  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end

    DatabaseCleaner.start

    Rails.cache.clear
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

RSpec::Matchers.define :be_d do |expected|
  match do |actual|
    if actual.respond_to?(:text)
      actual = actual.text unless actual.text.empty?
    end

    if actual.respond_to?(:value)
      actual = actual.value unless actual.value.empty?
    end

    if expected.kind_of? BigDecimal
      actual.to_d == expected
    elsif expected.kind_of? String
      actual.to_d == expected.to_d
    else
      raise "not support type #{expected.class}"
    end
  end

  failure_message_for_should do |actual|
    "expected #{actual.to_s} would be of #{expected.to_s}"
  end
end
