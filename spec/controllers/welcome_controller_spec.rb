# encoding: UTF-8
# frozen_string_literal: true

describe WelcomeController, type: :controller do
  describe 'ability to disable cabinet UI' do

    before { ENV['DISABLE_CABINET_UI'] = nil }

    context 'when cabinet UI is enabled' do
      it 'should return HTTP 200' do
        get :index
        expect(response).to have_http_status(200)
      end
    end

    context 'when cabinet UI is disabled' do
      before { ENV['DISABLE_CABINET_UI'] = 'true'}
      it 'should return HTTP 204' do
        get :index
        expect(response).to have_http_status(204)
      end
    end
  end
end
