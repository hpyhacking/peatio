def clear_cookie
  page.driver.cookies.each_key do |k|
    page.driver.remove_cookie k
  end
end
