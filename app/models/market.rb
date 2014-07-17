# People exchange commodities in markets. Each market focuses on certain
# commodity pair `{A, B}`. By convention, we call people exchange A for B
# *sellers* who submit *ask* orders, and people exchange B for A *buyers*
# who submit *bid* orders.
#
# ID of market is always in the form "#{B}#{A}". For example, in 'btccny'
# market, the commodity pair is `{btc, cny}`. Sellers sell out _btc_ for
# _cny_, buyers buy in _btc_ with _cny_. _btc_ is the `target`, while _cny_
# is the `price`.

class Market < ActiveYaml::Base
  include Enumerizeable

  set_root_path "#{Rails.root}/config"

  attr :name, :target_unit, :price_unit

  # TODO: our market id is the opposite of conventional market name.
  # e.g. our 'btccny' market should use 'btccny' as id, and its name should
  # be 'BTC/CNY'
  def initialize(*args)
    super

    raise ArgumentError, "market id must be 6 chars long (3 chars base currency code + 3 chars quote currency code, e.g. 'btccny')" if id.size != 6

    @target_unit = id[0,3]
    @price_unit  = id[3,3]
    @name = "#{@target_unit}/#{@price_unit}".upcase
  end

  def latest_price
    Trade.latest_price(id.to_sym)
  end

  # type is :ask or :bid
  def fix_number_precision(type, d)
    digits = send(type)['fixed']
    d.round digits, 2
  end

  def to_s
    id
  end

end
