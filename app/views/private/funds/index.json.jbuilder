json.current_user @current_user
json.currencies @currencies
json.deposits do
  @deposits.map do |deposit|
    deposit.as_json(except: :currency_id).merge!(currency: deposit.currency.code)
  end.tap { |collection| json.merge!(collection) }
end
json.accounts do
  @accounts.map do |account|
    account.as_json.merge!(currency_icon_url: currency_icon_url(account.currency))
  end.tap { |collection| json.merge!(collection) }
end
json.withdraws @withdraws
