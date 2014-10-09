require 'spec_helper'

describe Verify::GoogleAuthsController do
  let(:member) { create :member }
  before { session[:member_id] = member.id }

  describe 'GET /show/app' do
    before { get :show, id: :app }

    context 'not activated yet' do
      it { should respond_with :ok }
      it { should render_template(:show) }
      it "member should have two_factor prepared" do
        expect(member.two_factors).not_to be_empty
      end
    end

    context 'already activated' do
      let(:member) { create :member, :two_factor_activated }

      it { should redirect_to(settings_path) }
    end
  end

  describe 'get /edit' do
    before { get :edit, id: 'app' }

    context 'not activated' do
      let(:member) { create :member, :two_factor_inactivated }

      it { should redirect_to(settings_path) }
    end

    context 'activated' do
      let(:member) { create :member, :two_factor_activated }

      it { should respond_with :ok }
      it { should render_template(:edit) }
    end
  end
end
