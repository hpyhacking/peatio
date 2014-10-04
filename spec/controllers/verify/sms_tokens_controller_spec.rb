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

    describe 'POST verify/sms_tokens in send code phase' do
      let(:member) { create :member }
      let(:attrs) {
        {
          format: :js,
          token_sms_token: {phone_number: '123-1234-1234'},
          commit: 'send_code'
        }
      }

      before { session[:member_id] = member.id }

      it "create sms_token" do
        post :create, attrs
        expect(member.sms_token).to be_is_a(Token::SmsToken)
      end

      context "with empty number" do
        let(:attrs) {
          {
            format: :js,
            token_sms_token: {phone_number: ''},
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
            token_sms_token: {phone_number: 'wrong number'},
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
            token_sms_token: {phone_number: '123.1234.1234'},
            commit: 'send_code'
          }
        }

        before do
          post :create, attrs
        end

        it "return status ok" do
          expect(response).to be_ok
        end

        it "should update member's phone number" do
          expect(member.reload.phone_number).not_to be_blank
        end
      end
    end

    describe 'POST verify/sms_tokens in verify code phase' do
      let(:token) { create :token_sms_token }
      let(:member) { token.member }
      before { session[:member_id] = member.id }

      context "with empty code" do
        let(:attrs) {
          {
            format: :js,
            token_sms_token: {verify_code: ''}
          }
        }

        before do
          post :create, attrs
        end

        it "not return ok status" do
          expect(response).not_to be_ok
        end
      end

      context "with wrong code" do
        let(:attrs) {
          {
            format: :js,
            token_sms_token: {verify_code: 'foobar'}
          }
        }

        before do
          post :create, attrs
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
            token_sms_token: {verify_code: token.token}
          }
        }

        before do
          post :create, attrs
        end

        it "should update member#phone_number_verified" do
          expect(member.reload.phone_number_verified).to be_true
        end

        it "should mark token as used" do
          expect(token.reload.is_used).to be_true
        end

        it "should create instance of TwoFactor::Sms" do
          expect(member.two_factors.by_type(:sms)).to be_is_a(TwoFactor::Sms)
        end
      end
    end

  end
end
