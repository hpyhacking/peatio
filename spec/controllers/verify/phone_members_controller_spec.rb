require 'spec_helper'

module Verify
  describe PhoneNumbersController do

    describe 'GET new' do
      context 'verify phone number' do
        let(:member) { create :verified_member }
        before { session[:member_id] = member.id }
        subject(:do_request) { get :new }

        it { should be_success }
        it { should render_template(:new) }
      end

      context 'already verified' do
        let(:member) { create :verified_phone_number }
        before { session[:member_id] = member.id }
        subject(:do_request) { get :new }

        it { should be_redirect }
        it { should redirect_to(settings_path) }
      end
    end
  end
end
