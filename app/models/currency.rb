class Currency < ActiveYaml::Base
  set_root_path "#{Rails.root}/config"
  include ChannelInternational

  def self.codes
    @codes ||= Hash[*all.map do |x| [x.code, x.id] end.flatten].symbolize_keys
  end

  def api
    raise unless coin?
    CoinRPC[code]
  end
end
