# encoding: UTF-8
# frozen_string_literal: true

def clear_cookie
  page.driver.browser.manage.delete_all_cookies
end
