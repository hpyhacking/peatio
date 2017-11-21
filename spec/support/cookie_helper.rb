def clear_cookie
  page.driver.browser.manage.delete_all_cookies
end
