# encoding: UTF-8
# frozen_string_literal: true

describe Private::SettingsController, type: :controller do
  let(:member) { create :member, :level_3 }
  before { session[:member_id] = member.id }

  describe 'GET /index' do
    before { get :index }

    it { expect(response.status).to eq 200 }
    it { is_expected.to render_template(:index) }
  end
end
