require 'spec_helper'

describe Private::FundsController do

  context "Verified user with two factor" do
    let(:member) { create(:member, :activated, :verified, :app_two_factor_activated) }
    before { session[:member_id] = member.id }

    before do
      get :index
    end

    it { expect(response).to be_ok }
  end

  context "Verified user without two factor auth" do
    let(:member) { create(:member, :activated, :verified) }
    before { session[:member_id] = member.id }

    before do
      get :index
    end

    it { expect(member.two_factors).not_to be_activated }
    it { expect(response).to redirect_to(settings_path) }
  end

end
