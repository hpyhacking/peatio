module CurrencyHelper
  # Yaroslav Konoplov: I don't use #image_path & #image_url here
  # since Gon::Jbuilder attaches ActionView::Helpers which behave differently
  # compared to what ActionController does.
  def currency_icon_url(currency)
    if currency.coin?
      ActionController::Base.helpers.image_url "yarn_components/cryptocurrency-icons/svg/color/#{currency.code}.svg"
    else
      ActionController::Base.helpers.image_url "yarn_components/currency-flags/src/flags/#{currency.code}.png"
    end
  end
end
