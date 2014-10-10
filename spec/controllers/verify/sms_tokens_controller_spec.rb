require 'spec_helper'

module Verify
  describe SmsTokensController do

    describe 'GET verify/sms_token' do
      let(:member) { create :verified_member }
      before { session[:member_id] = member.id }

      before do
        get :show
      end

      it { expect(response).to be_success }
      it { expect(response).to render_template(:show) }

      context 'phone number has been verified' do
        let(:member) { create :member, :sms_two_factor_activated }

        it { should redirect_to(settings_path) }
      end
    end

    describe 'UPDATE verify/sms_token in send code phase' do
      let(:member) { create :member }
      let(:attrs) {
        {
          format: :js,
          sms_token: {phone_number: '123-1234-1234'},
          commit: 'send_code'
        }
      }

      before { session[:member_id] = member.id }

      it "create sms_token" do
        put :update, attrs
        expect(assigns(:token)).to be_is_a(Token::SmsToken)
      end

      context "with empty number" do
        let(:attrs) {
          {
            format: :js,
            sms_token: {phone_number: ''},
            commit: 'send_code'
          }
        }

        before { put :update, attrs }

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

        before { put :update, attrs }

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

        before do
          put :update, attrs
        end

        it "return status ok" do
          expect(response).to be_ok
        end

        it "should update member's phone number" do
          expect(member.reload.phone_number).not_to be_blank
        end
      end
    end

    describe 'POST verify/sms_token in verify code phase' do
      let(:token) { create :sms_token }
      let(:member) { token.member }
      before { session[:member_id] = member.id }

      context "with empty code" do
        let(:attrs) {
          {
            format: :js,
            sms_token: {verify_code: ''}
          }
        }

        before do
          put :update, attrs
        end

        it "not return ok status" do
          expect(response).not_to be_ok
        end
      end

      context "with wrong code" do
        let(:attrs) {
          {
            format: :js,
            sms_token: {verify_code: 'foobar'}
          }
        }

        before do
          put :update, attrs
        end

        it "not return ok status" do
          expect(response).not_to be_ok
        end

        it "has error message" do
          expect(response.body).not_to be_blank
        end
      end

      context "with right code" do
        let(:attrs) {
          {
            format: :js,
            sms_token: {verify_code: token.token}
          }
        }

        before do
          put :update, attrs
        end

        it "should mark token as used" do
          expect(token.reload.is_used).to be_true
        end

        it "should update instance of TwoFactor::Sms" do
          expect(member.sms_two_factor).to be_is_a(TwoFactor::Sms)
        end
      end
    end

  end
end
