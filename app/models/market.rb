# People exchange commodities in markets. Each market focuses on certain
# commodity pair `{A, B}`. By convention, we call people exchange A for B
# *sellers* who submit *ask* orders, and people exchange B for A *buyers*
# who submit *bid* orders.
#
# For example, in 'btcusd' market, the commodity pair is `{btc, usd}`.
# Sellers sell out _btc_ for _usd_, buyers buy in _btc_ with _usd_. _btc_
# is the `target`, while _usd_ is the `price`.

class Market < ActiveYaml::Base
  include Enumerizeable

  set_root_path "#{Rails.root}/config"
  set_filename "market"

  attr :name, :target_unit, :price_unit

  def initialize(*args)
    super

    @target_unit = id[0,3]
    @price_unit  = id[3,3]
    @name = "#{@target_unit}/#{@price_unit}".upcase

    @engine = Matching::FIFOEngine.new self
  end

  def submit(attrs)
    order = Matching::Order.new attrs
    @engine.submit order
    if @engine.match?
    end
  end

  def to_s
    id
  end

end

