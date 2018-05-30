# encoding: UTF-8
# frozen_string_literal: true

module Private::HistoryHelper
  def trade_side(trade)
    trade.ask_member_id == current_user.id ? 'sell' : 'buy'
  end

  def transaction_type(t)
    t(".#{t.class.superclass.name}")
  end

  def transaction_txid_link(t)
    return t.txid if t.txid.blank? || !t.currency.coin?
    link_to t.txid, t.transaction_url
  end
end
