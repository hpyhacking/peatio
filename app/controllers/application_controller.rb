class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_identity, :current_user, :is_admin?, :latest_market, :gon
  before_filter :set_language, :setting_default
  rescue_from CoinRPC::ConnectionRefusedError, with: :coin_rpc_connection_refused

  layout 'frame'

  def setting_default
    gon.env = Rails.env
    gon.market = Market.find(latest_market)
    gon.ticker = Global[latest_market].ticker
    gon.pusher_key = ENV["PUSHER_KEY"]

    gon.clipboard = {
      :click => I18n.t('actions.clipboard.click'),
      :done => I18n.t('actions.clipboard.done')
    }

    if current_user
      gon.current_user = {:sn => current_user.sn} 
    end
  end

  def latest_market
    params[:market] || cookies[:market] || ENV["DEFAULT_MARKET"]
  end

  def currency
    "#{params[:bid]}#{params[:ask]}".to_sym
  end

  def current_identity
    @current_identity ||= Identity.find_by_id(session[:identity_id])
  end

  def current_user
    @current_user ||= current_identity.try(:member)
  end

  def auth_member!
    redirect_to main_app.root_path unless current_identity
  end

  def auth_active!
    if current_identity && !@current_identity.reload.is_active?
      redirect_to main_app.new_activation_path
    end
  end

  def auth_no_initial!
    redirect_to main_app.root_path if current_user && current_user.initial?
  end

  def auth_anybody!
    redirect_to main_app.root_path if current_user
  end

  def is_admin?
    current_user.admin?
  end

  def auth_admin!
    redirect_to main_app.root_path unless is_admin?
  end

  private
  def set_language
    cookies[:lang] = params[:lang] unless params[:lang].blank?
    I18n.locale = cookies[:lang] || http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def coin_rpc_connection_refused
    render 'errors/connection'
  end
end
