json.current_user @current_user
json.deposit_channels @deposit_channels
json.withdraw_channels @withdraw_channels
json.currencies @currencies
json.deposits @deposits
json.accounts do
  @accounts.map do |account|
    # Yaroslav Konoplov: I don't use #image_path & #image_url here
    # since Gon::Jbuilder attaches ActionView::Helpers which behave differently
    # compared to what ActionController does.
    icon_url = if account.currency.coin?
      ActionController::Base.helpers.image_url "/icon-#{account.currency.code.downcase}.png"
    else
      ActionController::Base.helpers.image_url "yarn_components/currency-flags/src/flags/#{account.currency.code.downcase}.png"
    end
    account.as_json.merge!(currency_icon_url: icon_url)
  end.tap { |collection| json.merge!(collection) }
end
json.withdraws @withdraws
json.fund_sources @fund_sources
