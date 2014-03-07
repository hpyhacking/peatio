# People exchange commodities in markets. Each market focuses on certain
# commodity pair `{A, B}`. By convention, we call people exchange A for B
# *sellers* who submit *ask* orders, and people exchange B for A *buyers*
# who submit *bid* orders.
#
# ID of market is always in the form "#{B}#{A}". For example, in 'cnybtc'
# market, the commodity pair is `{btc, cny}`. Sellers sell out _btc_ for
# _cny_, buyers buy in _btc_ with _cny_. _btc_ is the `target`, while _cny_
# is the `price`.

class Market < ActiveYaml::Base
  include Enumerizeable

  set_root_path "#{Rails.root}/config"
  set_filename "market"

  attr :name, :target_unit, :price_unit

  # TODO: our market id is the opposite of conventional market name.
  # e.g. our 'cnybtc' market should use 'btccny' as id, and its name should
  # be 'BTC/CNY'
  def initialize(*args)
    super

    @price_unit  = id[0,3]
    @target_unit = id[3,3]
    @name = "#{@price_unit} - #{@target_unit}".upcase

    @engine = Matching::FIFOEngine.new self
  end

  def submit(attrs)
    order = Matching::Order.new attrs
    @engine.submit_and_run! order
  end

  def latest_price
    Trade.latest_price(id.to_sym)
  end

  def to_s
    id
  end

end

