class Currency < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"
  include ChannelInternational

  def self.codes
    @codes ||= Hash[*all.map do |x| [x.code, x.id] end.flatten].symbolize_keys
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

end
