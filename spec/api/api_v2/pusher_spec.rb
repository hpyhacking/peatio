# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Pusher, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }

  describe 'POST /pusher/auth' do
    subject do
      api_post '/api/v2/pusher/auth',
               token:  token,
               params: { channel_name: 'private-' + member.sn, socket_id: socket_id }
      response
    end
    let(:socket_id) { '7.87693' }
    let(:channel_token) { 'f9jxQLQ631LehgeAjjJZpg2iMiCeHAMW:582b749eefd5509ab33c74915f42ce6359eb0788e026c6784051c7c836ea41e3' }

    before do
      Pusher::Channel
        .any_instance
        .expects(:authenticate)
        .with(socket_id)
        .returns(auth: channel_token)
    end

    it do
      expect(subject).to have_http_status 201
      expect(subject.body).to eq JSON.dump(auth: channel_token)
    end
  end
end
