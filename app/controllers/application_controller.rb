class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :is_admin?, :current_market, :gon, :muut_enabled?
  before_filter :set_language, :setting_default, :set_timezone
  before_filter :set_current_user
  rescue_from CoinRPC::ConnectionRefusedError, with: :coin_rpc_connection_refused

  layout 'frame'

  def setting_default
    gon.env = Rails.env
    gon.local = I18n.locale
    gon.market = current_market.attributes
    gon.ticker = Global[current_market].ticker
    gon.pusher_key = ENV['PUSHER_KEY']
    gon.pusher_options = {
      wsHost:    ENV['PUSHER_HOST']     || 'ws.pusherapp.com',
      wsPort:    ENV['PUSHER_WS_PORT']  || '80',
      wssPort:   ENV['PUSHER_WSS_PORT'] || '443',
      encrypted: ENV['PUSHER_ENCRYPTED'] == 'true'
    }

    gon.clipboard = {
      :click => I18n.t('actions.clipboard.click'),
      :done => I18n.t('actions.clipboard.done')
    }

    if current_user
      gon.current_user = {:sn => current_user.sn}
    end
  end

  def currency
    "#{params[:ask]}#{params[:bid]}".to_sym
  end

  def current_market
    Market.find_by_id(params[:market]) || Market.find_by_id(cookies[:market_id]) || Market.first
  end

  def current_user
    @current_user ||= Member.enabled.where(id: session[:member_id]).first
  end

  def set_current_user
    Member.current = current_user
  end

  def auth_member!
    redirect_to root_path unless current_user
  end

  def auth_activated!
    redirect_to settings_path, alert: t('private.settings.index.auth-activated') unless current_user.activated?
  end

  def auth_verified!
    unless current_user and current_user.id_document and current_user.id_document_verified?
      redirect_to settings_path, alert: t('private.settings.index.auth-verified')
    end
  end

  def auth_no_initial!
  end

  def auth_anybody!
    redirect_to root_path if current_user
  end

  def auth_admin!
    redirect_to main_app.root_path unless is_admin?
  end

  def is_admin?
    current_user && current_user.admin?
  end

  def muut_enabled?
    !!ENV['MUUT_KEY']
  end

  private

  def two_factor_activated!
    if not current_user.two_factors.activated?
      redirect_to settings_path, alert: t('private.two_factors.auth.please_active_two_factor')
    end
  end

  def two_factor_auth_verified?
    return true if not current_user.two_factors.activated?

    two_factor = current_user.two_factors.by_type(params[:two_factor][:type])
    return false unless two_factor

    two_factor.assign_attributes params.require(:two_factor).permit(:otp)
    two_factor.verify
  end

  def set_language
    cookies[:lang] = params[:lang] unless params[:lang].blank?
    I18n.locale = cookies[:lang] || http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def set_timezone
    Time.zone = ENV['TIMEZONE'] if ENV['TIMEZONE']
  end

  def coin_rpc_connection_refused
    render 'errors/connection'
  end

  def save_session_key(member_id, key)
    Rails.cache.write "peatio:sessions:#{member_id}:#{key}", 1, expire_after: ENV['SESSION_EXPIRE'].to_i.minutes
  end

  def clear_all_sessions(member_id)
    redis = Rails.cache.instance_variable_get(:@data)
    redis.keys("peatio:sessions:*").each {|k| Rails.cache.delete k.split(':').last }

    Rails.cache.delete_matched "peatio:sessions:#{member_id}:*"
  end

end
