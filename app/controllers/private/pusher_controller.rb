require "openssl"

module Private
  class PusherController < BaseController
    protect_from_forgery :except => :auth
  
    def auth
      sn = params[:channel_name].split('-', 2).last
      if current_user && current_user.sn == sn
        response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
        render :json => response
      else
        render :text => "Forbidden", :status => '403'
      end
    end
  end
end
