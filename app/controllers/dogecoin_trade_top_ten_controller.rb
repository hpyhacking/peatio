class DogecoinTradeTopTenController < ApplicationController
  def index
    date = DateTime.new(2014,5,26,11,0,0)
    @result = DogecoinTrade.where('created_at < ?', date).group(:member_id).order('sum_volume desc').limit(10).select('sum(volume) as sum_volume, member_id').includes(:member)
  end
end
