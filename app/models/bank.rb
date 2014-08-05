class Bank < ActiveYamlBase
  include HashCurrencible

  def self.with_currency(c)
    find_all_by_currency c.to_s
  end
end
