json.current_user @current_user
json.deposit_channels @deposit_channels
json.withdraw_channels @withdraw_channels
json.currencies @currencies
json.deposits @deposits
json.accounts do
  @accounts.map do |account|
    account.as_json.merge!(currency_icon_url: currency_icon_url(account.currency))
  end.tap { |collection| json.merge!(collection) }
end
json.withdraws @withdraws
