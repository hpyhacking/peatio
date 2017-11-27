describe SessionsController, type: :controller do
  %i[ google_oauth2 auth0 ].each do |provider|
    describe "sign in using #{provider} provider" do
      before do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[provider]
      end

      after do
        request.env['omniauth.auth'] = nil
      end

      it 'should successfully create a member' do
        expect {
          post :create, provider: provider
        }.to change { Member.count }.by(1)
      end

      it 'should successfully create a session' do
        expect(session[:member_id]).to be_nil
        post :create, provider: provider
        expect(session[:member_id]).to_not be_nil
      end

      it 'should redirect the member to the settings url' do
        post :create, provider: provider
        expect(response).to redirect_to settings_url
      end

      it 'should successfully destroy a session' do
        post :create, provider: provider
        post :destroy
        expect(session[:member_id]).to be_nil
      end
    end
  end
end
