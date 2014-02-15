def clear_cookie
  page.driver.cookies.each do |k, v| 
    page.driver.remove_cookie k
  end
end

