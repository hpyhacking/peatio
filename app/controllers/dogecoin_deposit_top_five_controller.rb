class DogecoinDepositTopFiveController < ApplicationController
  def index
    @accounts = Deposits::Dogecoin.where('created_at < ?', DateTime.new(2014, 5, 15, 12, 0)).select("sum(amount) as top_amount, account_id as account_id, member_id as member_id").group("account_id").includes(:account, :member).order('top_amount desc')
  end
end
