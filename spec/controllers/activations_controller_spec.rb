require 'spec_helper'

module Private
  describe ActivationsController do

    describe "GET /activations/new" do
      describe 'non-login user' do
        before { get :new }

        it { expect(response).to redirect_to(root_path) }
        it { expect(flash[:alert]).to match('login required') }
      end

      describe 'logged-in user but not activated yet' do
        let(:member) { create :member }
        let(:mail) { ActionMailer::Base.deliveries.last }
        before {
          session[:member_id] = member.id
          get :new
        }

        it { expect(member).not_to be_activated }
        it { expect(response).to redirect_to(settings_path) }
        it { expect(mail.subject).to match('Account Activation') }
      end

      describe 'logged-in user and verified already' do
        let(:member) { create :member, :activated }
        before {
          session[:member_id] = member.id
          get :new
        }

        it { expect(response).to redirect_to(settings_path) }
        it { expect(flash[:notice]).to match('has been verified successfully') }
      end
    end

  end
end
