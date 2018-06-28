# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::WebSocketProtocol do
  include EM::SpecHelper

  let(:conn) { BunnyMock.new.start }
  let(:channel) { conn.channel }
  let(:logger) { Rails.logger }
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:ws_client) { EventMachine::WebSocketClient.connect("ws://#{ENV.fetch('WEBSOCKET_HOST')}:#{ENV.fetch('WEBSOCKET_PORT')}/") }

  context 'valid token' do
    before do
      APIv2::WebSocketProtocol.any_instance.stubs(:subscribe_orders)
      APIv2::WebSocketProtocol.any_instance.stubs(:subscribe_trades)
    end
    it 'access granted' do
      em {
        ws_server do |ws|
          protocol = APIv2::WebSocketProtocol.new(ws, channel, logger)
          ws.onmessage { |msg| protocol.handle msg }
          ws.onclose{ |status|
            expect(status[:code]).to eq 1006 # Unclean
            expect(status[:was_clean]).to be false
          }
        end

        EM.add_timer(0.1) do
          auth_msg = {jwt: "Bearer #{token}"} # valid token
          ws_client.callback { ws_client.send_msg auth_msg.to_json}
          ws_client.disconnect { done }
          ws_client.stream { |msg|
            expect(msg.data).to eq "{\"success\":{\"message\":\"Authenticated.\"}}"
            done
          }
        end
      }
    end
  end

  context 'invalid token' do
    it 'denies access' do
      em {
        ws_server do |ws|
          protocol = APIv2::WebSocketProtocol.new(ws, channel, logger)
          ws.onmessage { |msg| protocol.handle msg }
          ws.onclose{ |status|
            expect(status[:code]).to eq 1006 # Unclean
            expect(status[:was_clean]).to be false
          }
        end

        EM.add_timer(0.1) do
          auth_msg = {jwt: "Bearer #{token}y"} #invalid token
          ws_client.callback { ws_client.send_msg auth_msg.to_json}
          ws_client.disconnect { done }
          ws_client.stream { |msg|
            expect(msg.data).to eq "{\"error\":{\"message\":\"Authentication failed.\"}}"
            done
          }
        end
      }
    end
  end

end

