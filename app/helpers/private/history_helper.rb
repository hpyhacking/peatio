module Private::HistoryHelper

  def trade_side(trade)
    trade.ask_member == current_user ? 'sell' : 'buy'
  end

end
