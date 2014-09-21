module Private
  class DepositsController < BaseController
    before_action :auth_activated!
    before_action :auth_verified!

    if ENV['URL_HOST'] == 'stg.peatio.com'
      HIDDEN_CHANNEL = %w()
    else
      HIDDEN_CHANNEL = %w(btsx)
    end

    def index
      @deposits = DepositChannel.all.select{|c| !HIDDEN_CHANNEL.include?(c.currency)}.sort
    end

  end
end
