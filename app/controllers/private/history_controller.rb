# encoding: UTF-8
# frozen_string_literal: true

module Private
  class HistoryController < BaseController

    helper_method :tabs

    def account
      @market = current_market

      @deposits = Deposit.where(member: current_user, aasm_state: :accepted).includes(:currency)
      @withdraws = Withdraw.where(member: current_user, aasm_state: :succeed).includes(:currency)

      @transactions = (@deposits + @withdraws).sort_by {|t| -t.created_at.to_i }
      @transactions = Kaminari.paginate_array(@transactions).page(params[:page]).per(20)
    end

    def trades
      @trades = current_user.trades
        .includes(:market)
        .order('id desc').page(params[:page]).per(20)
    end

    def orders
      @orders = current_user.orders.order("id desc").page(params[:page]).per(20)
    end

    private

    def tabs
      { order: ['header.order_history', order_history_path],
        trade: ['header.trade_history', trade_history_path],
        account: ['header.account_history', account_history_path] }
    end

  end
end
