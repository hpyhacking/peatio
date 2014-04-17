require 'spec_helper'

module Verify
  describe SmsTokensController do

    describe 'GET verify/sms_tokens/new' do
      let(:member) { create :verified_member }
      before { session[:member_id] = member.id }
      subject(:do_request) { get :new }

      it { should be_success }
      it { should render_template(:new) }

      context 'phone number has been verified' do
        let(:member) { create :verified_phone_number }

        it { should be_redirect }
        it { should redirect_to(settings_path) }
      end
    end

    describe 'POST verify/sms_tokens' do
      let(:member) { create :member }

      before { session[:member_id] = member.id }

      it "create sms_token" do
        post :create, format: :js
        expect(member.sms_token).to be_is_a(SmsToken)
      end

      context "with empty number" do
        let(:attrs) {
          {
            format: :js,
            sms_token: {phone_number: ''},
            commit: 'send_code'
          }
        }

        before { post :create, attrs }

        it "should not be ok" do
          expect(response).not_to be_ok
        end
      end

      context "with wrong number" do
        let(:attrs) {
          {
            format: :js,
            sms_token: {phone_number: 'wrong number'},
            commit: 'send_code'
          }
        }

        before { post :create, attrs }

        it "should not be ok" do
          expect(response).not_to be_ok
        end

        it "should has error message" do
          expect(response.body).not_to be_blank
        end
      end

      context "with right number" do
        let(:attrs) {
          {
            format: :js,
            sms_token: {phone_number: '123.1234.1234'},
            commit: 'send_code'
          }
        }

        before { post :create, attrs }

        it "return status ok" do
          expect(response).to be_ok
        end

        it "should update member's phone number" do
          expect(member.reload.phone_number).not_to be_blank
        end

        it "should sent code through SMS" do

        end
      end
    end

  end
end
