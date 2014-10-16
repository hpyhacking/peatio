require 'spec_helper'

module Authentications
  describe EmailsController do
    let(:member) { create(:member, email: nil, activated: false) }
    before { session[:member_id] = member.id }

    describe 'GET new' do
      subject { get :new }

      it { should be_success }

      it  do
        get :new
        flash[:info].should == t('authentications.emails.new.setup_email')
      end
    end

    describe 'POST create' do
      let(:data) {
        { email: { address: 'xman@xman.com', user_id: '2' } }
      }

      it "should update current_user's email" do
        post :create, data
        member.reload
        member.email.should == 'xman@xman.com'
        member.activated.should be_false
      end
    end

  end
end
