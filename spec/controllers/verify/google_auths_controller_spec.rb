require 'spec_helper'

describe Verify::GoogleAuthsController do
  let(:member) { create :member }
  before { session[:member_id] = member.id }

  describe 'GET /show' do
    before { get :show }

    context 'not activated yet' do
      it { should respond_with :ok }
      it { should render_template(:show) }
      it "member should have two_factor prepared" do
        expect(member.two_factors).not_to be_empty
      end
    end

    context 'already activated' do
      let(:member) { create :member, :app_two_factor_activated }

      it { should redirect_to(settings_path) }
    end
  end

  describe 'get /edit' do
    context 'not activated' do
      before { get :edit }

      it { expect(member.app_two_factor).not_to be_activated }
      it { should redirect_to(settings_path) }
    end

    context 'activated' do
      let(:member) { create :member, :app_two_factor_activated }
      before { session[:member_id] = member.id }

      before { get :edit }

      it { should respond_with :ok }
      it { should render_template(:edit) }
    end
  end
end
