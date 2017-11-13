module Verify
  describe SmsAuthsController, type: :controller do
    describe 'GET verify/sms_auth' do
      let(:member) { create :verified_member }
      before { session[:member_id] = member.id }

      before do
        get :show
      end

      it { expect(response).to be_success }
      it { expect(response).to render_template(:show) }

      context 'already verified' do
        let(:member) { create :member, :sms_two_factor_activated }

        it { is_expected.to redirect_to(settings_path) }
      end
    end

    describe 'PUT verify/sms_auth in send code phase' do
      let(:member) { create :member }
      let(:attrs) do
        {
          format: :js,
          sms_auth: { country: 'CN', phone_number: '123-1234-1234' },
          commit: 'send_code'
        }
      end

      subject { assigns(:sms_auth) }

      before do
        session[:member_id] = member.id
        put :update, attrs
      end

      it { is_expected.not_to be_nil }

      it 'otp_secret' do
        expect(subject.otp_secret).not_to be_blank
      end

      context 'with empty number' do
        let(:attrs) do
          {
            format: :js,
            sms_auth: { country: '', phone_number: '' },
            commit: 'send_code'
          }
        end

        before { put :update, attrs }

        it 'should not be ok' do
          expect(response).not_to be_ok
        end
      end

      context 'with wrong number' do
        let(:attrs) do
          {
            format: :js,
            sms_auth: { country: 'CN', phone_number: 'wrong number' },
            commit: 'send_code'
          }
        end

        before { put :update, attrs }

        it 'should not be ok' do
          expect(response).not_to be_ok
        end

        it 'should has error message' do
          expect(response.body).not_to be_blank
        end
      end

      context 'with right number' do
        let(:attrs) do
          {
            format: :js,
            sms_auth: { country: 'CN', phone_number: '133.1234.1234' },
            commit: 'send_code'
          }
        end

        before do
          put :update, attrs
        end

        it { expect(response).to be_ok }
        it { expect(member.reload.phone_number).to eq('8613312341234') }
      end
    end

    describe 'POST verify/sms_auth in verify code phase' do
      let(:member) { create :member }
      let(:sms_auth) { member.sms_two_factor }
      before { session[:member_id] = member.id }

      context 'with empty code' do
        let(:attrs) do
          {
            format: :js,
            sms_auth: { otp: '' }
          }
        end

        before do
          put :update, attrs
        end

        it 'not return ok status' do
          expect(response).not_to be_ok
        end
      end

      context 'with wrong code' do
        let(:attrs) do
          {
            format: :js,
            sms_auth: { otp: 'foobar' }
          }
        end

        before do
          put :update, attrs
        end

        it 'not return ok status' do
          expect(response).not_to be_ok
        end

        it 'has error message' do
          expect(response.body).not_to be_blank
        end
      end

      context 'with right code' do
        let(:attrs) do
          {
            format: :js,
            sms_auth: { otp: sms_auth.otp_secret }
          }
        end

        before do
          put :update, attrs
        end

        it { expect(response).to be_ok }
        it { expect(assigns(:sms_auth)).to be_activated }
        it { expect(member.sms_two_factor).to be_activated }
      end
    end
  end
end
