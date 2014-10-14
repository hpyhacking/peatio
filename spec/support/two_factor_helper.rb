def two_factor_unlocked
  session[:two_factor_unlock] = true
  session[:two_factor_unlock_at] = Time.now
end
