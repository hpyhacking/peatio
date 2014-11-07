# Set locale in ActionController::Base because Doorkeeper controllers extend
# directly from it, and it's hard to patch those controllers.
class ActionController::Base

  before_action :set_language

  private

  def set_language
    cookies[:lang] = params[:lang] unless params[:lang].blank?
    locale = cookies[:lang] || http_accept_language.compatible_language_from(I18n.available_locales)
    I18n.locale = locale if locale && I18n.available_locales.include?(locale.to_sym)
  end

end
