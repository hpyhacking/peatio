screen_size = [1280, 800]

if ENV.key?('SELENIUM_HOST')
  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new \
      app,
      url:                  "http://#{ENV.fetch('SELENIUM_HOST')}:#{ENV.fetch('SELENIUM_PORT')}/wd/hub",
      browser:              :remote,
      desired_capabilities: :chrome
  end

  Capybara.app_host   = "http://#{ENV.fetch('TEST_APP_HOST')}:#{ENV.fetch('TEST_APP_PORT')}"
  Capybara.run_server = false

  RSpec.configure do |config|
    config.before :each, type: :feature do
      Capybara.current_session.driver.browser.manage.window.resize_to(*screen_size)
    end
  end
else
  Capybara.register_driver :chrome do |app|
    headless = !ENV['CHROME_HEADLESS'].in?(%w[ 0 false ])
    debug    = ENV['CHROME_DEBUG'].in?(%w[ 1 true ])

    driver_options = { args: [] }
    driver_options[:args] << '--log-path=' + Rails.root.join('log/chromedriver.log').to_s
    driver_options[:args] << '--verbose' if debug

    browser_options = Selenium::WebDriver::Chrome::Options.new
    browser_options.args << '--headless' if headless
    browser_options.args << '--disable-gpu'
    browser_options.args << '--ignore-certificate-errors'
    browser_options.args << '--disable-popup-blocking'
    browser_options.args << '--window-size=' + screen_size.join('x')
    browser_options.args << '--disable-extensions'

    Capybara::Selenium::Driver.new app, \
      browser:     :chrome,
      options:     browser_options,
      driver_opts: driver_options
  end

  Capybara.server_host = ENV.fetch('TEST_SERVER_HOST')
  Capybara.server_port = ENV.fetch('TEST_SERVER_PORT')
  Capybara.app_host    = "http://#{ENV.fetch('TEST_APP_HOST')}:#{ENV.fetch('TEST_APP_PORT')}"
end

Capybara.default_driver        = :chrome
Capybara.javascript_driver     = :chrome
Capybara.default_max_wait_time = 5
