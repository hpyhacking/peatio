def who_is_billionaire(name)
  member = create(:member, name: name)
  member.get_account(:btc).update_attributes(
    locked: '1000000000.0'.to_d, balance: '1000000000.0'.to_d)
  member.get_account(:cny).update_attributes(
    locked: '1000000000.0'.to_d, balance: '1000000000.0'.to_d)
  member
end

def print_time(time_hash)
  msg = time_hash.map{|k,v| "#{k}: #{v}"}.join(", ")
  puts "    \u25BC #{msg}"
end

module Matching

  class <<self
    def mock_order(attrs)
      Matching::Order.new({
        id: Time.now.to_i,
        timestamp: Time.now.to_i,
        volume: 1+rand(10),
        target: 1+rand(10),
        price:  3000+rand(3000)
      }.merge(attrs))
    end
  end

end
