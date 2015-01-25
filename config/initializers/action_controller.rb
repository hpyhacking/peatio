# ActionController::Base are used by both Peatio controllers and
# Doorkeeper controllers.
class ActionController::Base

  before_action :set_language

  private

  def set_language
    cookies[:lang] = params[:lang] unless params[:lang].blank?
    locale = cookies[:lang] || http_accept_language.compatible_language_from(I18n.available_locales)
    I18n.locale = locale if locale && I18n.available_locales.include?(locale.to_sym)
  end

  def set_redirect_to
    if request.get?
      uri = URI(request.url)
      cookies[:redirect_to] = "#{uri.path}?#{uri.query}"
    end
  end

end
