# encoding: UTF-8
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionUtils
  extend Memoist

  protect_from_forgery with: :exception

  helper_method :current_user, :is_admin?, :current_market, :gon
  before_action :set_language, :set_gon
  around_action :share_user

private

  def current_market
    unless params[:market].blank?
      Market.enabled.find_by_id(params[:market])
    end || Market.enabled.ordered.first
  end
  memoize :current_market

  def current_user
    return if session[:member_id].blank?
    Member.enabled.find_by_id(session[:member_id])
  end
  memoize :current_user

  def auth_member!
    unless current_user
      redirect_to root_path, alert: t('activations.new.login_required')
    end
  end

  def auth_anybody!
    redirect_to root_path if current_user
  end

  def auth_admin!
    redirect_to root_path unless is_admin?
  end

  def is_admin?
    current_user&.admin?
  end

  def set_gon
    gon.environment = Rails.env
    gon.local = I18n.locale
    gon.market = current_market.attributes
    gon.ticker = current_market.ticker
    gon.markets = Market.enabled.each_with_object({}) { |market, memo| memo[market.id] = market.as_json }
    gon.host = request.base_url

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

    gon.currencies = Currency.enabled.inject({}) do |memo, currency|
      memo[currency.code] = {
        code: currency.code,
        symbol: currency.symbol,
        isCoin: currency.coin?
      }
      memo
    end
    gon.display_currency = ENV.fetch('DISPLAY_CURRENCY')
    gon.fiat_currencies = Currency.enabled.ordered.fiats.codes

    gon.tickers = {}
    Market.enabled.each do |market|
      gon.tickers[market.id] = market.unit_info.merge(Global[market.id].ticker)
    end

    if current_user
      gon.user = {
        sn: current_user.sn
      }
      gon.accounts = current_user.accounts.enabled.includes(:currency).inject({}) do |memo, account|
        memo[account.currency.code] = {
          currency: account.currency.code,
          balance: account.balance,
          locked: account.locked
        } if account.currency.try(:enabled)
        memo
      end
    end

    gon.bank_details_html = ENV['BANK_DETAILS_HTML']

    gon.barong_domain = ENV["BARONG_DOMAIN"]

    gon.ranger_host = ENV["RANGER_HOST"] || '0.0.0.0'
    gon.ranger_port = ENV["RANGER_PORT"] || '8081'
    gon.ranger_connect_secure = ENV["RANGER_CONNECT_SECURE"] || false
  end

  def set_language
    cookies[:lang] = params[:lang] unless params[:lang].blank?
    cookies[:lang].tap do |locale|
      I18n.locale = locale if locale.present? && I18n.available_locales.include?(locale.to_sym)
    end
  end

  def share_user
    Member.current = current_user
    yield
  ensure
    # http://stackoverflow.com/questions/2513383/access-current-user-in-model
    # To address the thread variable leak issues in Puma/Thin webserver
    Member.current = nil
  end
end
