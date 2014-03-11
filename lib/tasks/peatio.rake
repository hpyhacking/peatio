namespace :peatio do
  namespace :update do
    desc "Add ask_member_sn and bid_member_sn to trades"
    task add_ask_member_sn_and_bid_member_sn_to_trades: :environment do
      Trade.find_each do |trade|
        trade.update_attributes \
          ask_member_sn: trade.ask.member.sn,
          bid_member_sn: trade.bid.member.sn
      end
    end
  end
end
