# People exchange commodities in markets. Each market focuses on certain
# commodity pair, e.g. {btc, usd}, and by convention, people sell the first
# commodity (btc) for the second commodity (usd) in such a market.
#
# People hold btc coins are sellers, they create ask orders; people with
# usd are buyers, they create bid orders.

class Market < ActiveYaml::Base
  include Enumerizeable

  set_root_path "#{Rails.root}/config"
  set_filename "market"

  attr :name, :commodity

  def initialize(*args)
    super

    @commodity = {ask: id[0,3], bid: id[3,3]}
    @name = @commodity.values.map(&:upcase).join('/')
  end

  def submit_order(attrs)
  end

  def to_s
    id
  end

end

