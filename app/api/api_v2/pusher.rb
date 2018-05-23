# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Pusher < Grape::API
    before { authenticate! }

    desc 'Returns the credentials used to subscribe to private Pusher channel. ' \
         'IMPORTANT: Pusher events are not part of Peatio public interface. ' \
         'The events may be changed or removed in further releases. Use this on your own risk.'
    params do
      requires :channel_name, type: String, desc: 'The name of the channel being subscribed to. Example: private-SN362ECB6F7D.'
      requires :socket_id, type: String, desc: 'An unique identifier for the connected client.'
    end
    post '/pusher/auth' do
      sn = params[:channel_name].split('-', 2).last
      if current_user.sn == sn
        body ::Pusher[params[:channel_name]].authenticate(params[:socket_id])
        status 201
      else
        status 422
      end
    end
  end
end
