class ApplicationController < ActionController::Base
  include SessionUtils
  protect_from_forgery with: :exception

  helper_method :current_user, :is_admin?, :current_market, :gon
  before_action :set_timezone, :set_gon
  after_action :allow_iframe
  rescue_from CoinAPI::ConnectionRefusedError, with: :coin_rpc_connection_refused

  private

  def currency
    "#{params[:ask]}#{params[:bid]}".to_sym
  end

  def current_market
    @current_market ||= Market.find_by(id: params[:market]) || Market.find_by(id: cookies[:market_id]) || Market.first
  end

  def redirect_back_or_settings_page
    if cookies[:redirect_to].present?
      redirect_to URI.parse(cookies[:redirect_to]).path
      cookies[:redirect_to] = nil
    else
      redirect_to settings_path
    end
  end

  def current_user
    @current_user ||= Member.current = Member.enabled.where(id: session[:member_id]).first
  end

  def auth_member!
    unless current_user
      set_redirect_to
      redirect_to root_path, alert: t('activations.new.login_required')
    end
  end

  def auth_verified!
    if current_user.level.present? && !current_user.level.identity_verified?
      redirect_to settings_path, alert: t('private.settings.index.auth-verified')
    end
  end

  def auth_anybody!
    redirect_to root_path if current_user
  end

  def auth_admin!
    redirect_to main_app.root_path unless is_admin?
  end

  def is_admin?
    current_user&.admin?
  end

  def set_timezone
    Time.zone = ENV['TIMEZONE'] if ENV['TIMEZONE']
  end

  def set_gon
    gon.environment = Rails.env
    gon.local = I18n.locale
    gon.market = current_market.attributes
    gon.ticker = current_market.ticker
    gon.markets = Market.find_each.each_with_object({}) { |market, memo| memo[market.id] = market.as_json }
    gon.host = request.base_url
    gon.pusher = {
      key:       ENV.fetch('PUSHER_CLIENT_KEY'),
      wsHost:    ENV.fetch('PUSHER_CLIENT_WS_HOST'),
      httpHost:  ENV['PUSHER_CLIENT_HTTP_HOST'],
      wsPort:    ENV.fetch('PUSHER_CLIENT_WS_PORT'),
      wssPort:   ENV.fetch('PUSHER_CLIENT_WSS_PORT'),
    }.reject { |k, v| v.blank? }
     .merge(encrypted: ENV.fetch('PUSHER_CLIENT_ENCRYPTED').present?)

    gon.clipboard = {
      :click => I18n.t('actions.clipboard.click'),
      :done => I18n.t('actions.clipboard.done')
    }

    gon.i18n = {
      ask: I18n.t('gon.ask'),
      bid: I18n.t('gon.bid'),
      cancel: I18n.t('actions.cancel'),
      latest_trade: I18n.t('private.markets.order_book.latest_trade'),
      switch: {
        notification: I18n.t('private.markets.settings.notification'),
        sound: I18n.t('private.markets.settings.sound')
      },
      notification: {
        title: I18n.t('gon.notification.title'),
        enabled: I18n.t('gon.notification.enabled'),
        new_trade: I18n.t('gon.notification.new_trade')
      },
      time: {
        minute: I18n.t('chart.minute'),
        hour: I18n.t('chart.hour'),
        day: I18n.t('chart.day'),
        week: I18n.t('chart.week'),
        month: I18n.t('chart.month'),
        year: I18n.t('chart.year')
      },
      chart: {
        price: I18n.t('chart.price'),
        volume: I18n.t('chart.volume'),
        open: I18n.t('chart.open'),
        high: I18n.t('chart.high'),
        low: I18n.t('chart.low'),
        close: I18n.t('chart.close'),
        candlestick: I18n.t('chart.candlestick'),
        line: I18n.t('chart.line'),
        zoom: I18n.t('chart.zoom'),
        depth: I18n.t('chart.depth'),
        depth_title: I18n.t('chart.depth_title')
      },
      place_order: {
        confirm_submit: I18n.t('private.markets.show.confirm'),
        confirm_cancel: I18n.t('private.markets.show.cancel_confirm'),
        price: I18n.t('private.markets.place_order.price'),
        volume: I18n.t('private.markets.place_order.amount'),
        sum: I18n.t('private.markets.place_order.total'),
        price_high: I18n.t('private.markets.place_order.price_high'),
        price_low: I18n.t('private.markets.place_order.price_low'),
        full_bid: I18n.t('private.markets.place_order.full_bid'),
        full_ask: I18n.t('private.markets.place_order.full_ask')
      },
      trade_state: {
        new: I18n.t('private.markets.trade_state.new'),
        partial: I18n.t('private.markets.trade_state.partial')
      }
    }

    gon.currencies = Currency.visible.inject({}) do |memo, currency|
      memo[currency.code] = {
        code: currency.code,
        symbol: currency.symbol,
        isCoin: currency.coin?
      }
      memo
    end
    gon.display_currency = ENV.fetch('DISPLAY_CURRENCY')
    gon.fiat_currencies = Currency.fiats.pluck(:code)

    gon.tickers = {}
    Market.all.each do |market|
      gon.tickers[market.id] = market.unit_info.merge(Global[market.id].ticker)
    end

    if current_user
      gon.user = { sn: current_user.sn }
      gon.accounts = current_user.accounts.inject({}) do |memo, account|
        memo[account.currency.code] = {
          currency: account.currency.code,
          balance: account.balance,
          locked: account.locked
        } if account.currency.try(:visible)
        memo
      end
    end

    gon.bank_details_html = ENV['BANK_DETAILS_HTML']
  end

  def coin_rpc_connection_refused
    render 'errors/connection'
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options' if Rails.env.development?
  end
end
