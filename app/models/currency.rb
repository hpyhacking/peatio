class Currency < ActiveYaml::Base
  include International
  include ActiveHash::Associations

  set_root_path "#{Rails.root}/config"

  def self.hash_codes
    @codes ||= Hash[*all.map do |x| [x.code, x.id] end.flatten].symbolize_keys
  end

  def self.codes
    @keys ||= all.map do |x| x.code end
  end

  def self.assets(code)
    find_by_code(code)[:assets]
  end

  def api
    raise unless coin?
    CoinRPC[code]
  end

  def blockchain_url(txid)
    raise unless coin?
    blockchain.gsub('#{txid}', txid)
  end

  def address_url(address)
    raise unless coin?
    self[:address_url].try :gsub, '#{address}', address
  end
end
