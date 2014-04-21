require 'spec_helper'

describe Private::TwoFactorsController do
  let(:member) { create :member }
  before { session[:member_id] = member.id }

  describe 'GET /new' do
    before { get :new }

    context 'not activated' do
      it { should respond_with :ok }
      it { should render_template(:new) }
      it "member should have two_factor prepared" do
        expect(member.two_factor).not_to be_nil
      end
    end

    context 'activated' do
      let(:member) { create :member, :two_factor_activated }

      it { should redirect_to(settings_path) }
    end
  end

  describe 'get /edit' do
    before { get :edit }

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
