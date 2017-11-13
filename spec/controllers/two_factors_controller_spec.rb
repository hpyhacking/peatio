describe TwoFactorsController, type: :controller do
  describe 'GET :show' do
    let(:member) { create :member, :sms_two_factor_activated }
    before { session[:member_id] = member.id }

    context 'send sms verify code' do
      let(:do_request) { get :show, id: :sms, refresh: true }

      it do
        AMQPQueue.expects(:enqueue).with(:sms_notification, anything)
        do_request
      end
    end

    context 'two factor auth not locked' do
      let(:do_request) { get :show, id: :sms }

      before { do_request }

      it { expect(response).to be_ok }
    end

    context 'two factor auth locked' do
      let(:do_request) { get :show, id: :sms }

      before do
        controller.stubs(:two_factor_failed_locked?).returns(true)
        do_request
      end

      render_views

      it { expect(response).not_to be_ok }
      it { expect(response.status).to eq(423) }
      it { expect(response.body).not_to be_blank }
    end
  end

  describe 'GET :index' do
    context 'member without two_factor' do
      let(:member) { create :member }
      before { session[:member_id] = member.id }

      before { get :index }

      it { expect(response).to redirect_to(settings_path) }
    end

    context 'member with sms_two_factor activated' do
      let(:member) { create :member, :sms_two_factor_activated }
      before { session[:member_id] = member.id }

      before { get :index }

      it { expect(response).to be_ok }
      it { expect(response).to render_template('index') }
    end
  end

  describe 'PUT :update' do
    let(:member) { create :member, :sms_two_factor_activated }

    context 'with wrong otp' do
      let(:attrs) do
        { id: :sms,
          two_factor: { type: :sms,
                        otp: 'wrong code' } }
      end

      before do
        session[:member_id] = member.id
        put :update, attrs
      end

      it { expect(response).to redirect_to(two_factors_path) }
      it { expect(flash[:alert]).to match('verification code error') }
    end

    context 'with right otp' do
      let(:attrs) do
        { id: :sms,
          two_factor: { type: :sms,
                        otp: member.sms_two_factor.otp_secret } }
      end

      before do
        session[:member_id] = member.id
        put :update, attrs
      end

      it { expect(response).to redirect_to(settings_path) }
      it { expect(session[:two_factor_unlock]).to be true }
      it { expect(session[:two_factor_unlock_at]).not_to be_blank }
    end
  end
end
